---
title: Property Based Testing
lang: en
toc-title: Contents
pagetitle: Property Based Testing
---

# Property Based Testing

Using unit testing to verify code correct is not always effective. The code contracts
encode the specification, we there for only have to show that the code we wrote
does not breach the contract to verify the code.

We can represent a program or section of a program, unit, as a mathematical function
 $(f)$. All possible legal permutations of inputs are the function's domain $(I)$ and
the outputs are the function's range $(O)$.

$$ f: I \rightarrow O $$

It would be impractical to write unit tests that cover the complete domain
of a unit. Instead we randomly select inputs from the domain. When we tests smaller
units, random testing is adequate [[2]](####-2).
We are not going to verify the outputs because,
if the outputs adhere to the contracts we assume the outputs are valid. This will
eliminate the oracle problem [[1]](####-1) [[2]](####-2).

We will be using FsCheck to select the random inputs. FsCheck is a .net implementation
of QuickCheck [[3]](####-3). We use the xUnit test framework to make
writing the test more convenient.

The tests have two parts, the input generators and tests action. We first look at the generators.
We group the test inputs using tuples. The generator code filters the generated value according to the contracts.

# Properties

Properties are created in methods marked as ```[Property]``` and returning a ```Property```.
Properties must not have generic types. Properties can have any number of parameters.

```csharp
[Property]
public Property Property_method(int[] values, ⋯)
{
    ⋯
    return ⋯.ToProperty();
}
```

Properties can be created from:

- a boolean value indicating tests status;
  
```csharp
[Property]
public Property Reverse_Reverse_has_no_effect(int[] values)
{
   var list = new List<int>(values);
   list.Reverse();
   list.Reverse();
   return list.SequenceEqual(values).ToProperty();
}
```

- a function returning a boolean indicating test status;
  
```csharp
[Property]
public Property Reverse_Reverse_has_no_effect(int[] values)
{
   Func<bool> test = () =>
   {
      var list = new List<int>(values);
      list.Reverse();
      list.Reverse();
      return list.SequenceEqual(values);
   };
   return test.ToProperty();
}
```

- an action with any number of properties. Exceptions indicate test failure.
  
```csharp
[Property]
public Property Reverse_Reverse_has_no_effect(int[] values)
{
   Action test = () =>
   {
      var list = new List<int>(values);
      list.Reverse();
      list.Reverse();
      if (list.SequenceEqual(values))
            throw new Exception("The reversal failed");
   };
   return test.ToProperty();
}
```

## Conditional Properties

To use conditional properties the tests have to be warped in a ```Func``` or ```Action```.
Test cases that do not satisfy the conditions are discarded. Test cases are generated unit the required number of tests cases satisfying the conditions are run. (There is a caveat: https://github.com/fscheck/FsCheck/issues/245)

```csharp
[Property]
public Property Dividing_by_self_is_1(int x)
{
    Func<bool> test = () =>
    {
        var quotient = MyMath.Divide(x, x);
        return quotient == 1;
    };

    return test.When(x != 0);
}
```

## Quantified Properties

You create your own input using [generators, shrinkers and arbitrary instances](#generators-shrinkers-and-arbitrary-instances).

## Expecting exceptions

To test that code throws an exception.

```csharp
[Property]
public Property Dividing_By_Zero_Raises_Exception(int x)
{
    return
        Prop
        .Throws<DivideByZeroException, int>(
            new Lazy<int>(() => MyMath.Divide(x, 0)));
}
```

## Observing Test Cases

If test cases are not well distributed the test results may be invalid. Filtering tests cases can skew test case distribution.

### Counting Trivial Cases

Test cases that do not properly test the code or only tests a small part of the code are considered trivial.

```csharp
[Property]
public Property Reverse_Reverse_has_no_effect(int[] values)
{
    Func<bool> test = () =>
    {
        var list = new List<int>(values);
        list.Reverse();
        list.Reverse();
        return list.SequenceEqual(values);
    };

    return
        test
        .Trivial(values.Length < 2);
}
```

**Output** :
``` 
Ok, passed 100 tests (3% trivial)
```

### Classifying Test Cases

You can also create a more detailed breakdown of the test cases by classifying them into categories.

```csharp
[Property]
public Property Dividing_by_self_is_1(int x)
{
    Func<bool> test = () =>
    {
        var quotient = MyMath.Divide(x, x);
        return quotient == 1;
    };

    return
        test
        .When(x != 0)
        .Classify(x > 0, "Positive numbers")
        .Classify(x < 0, "Negative numbers");
}
```

**Output**:
```
Ok, passed 100 tests.
54% Negative numbers.
46% Positive numbers.
```

### Collecting Data Values

If you don't want to divide test cases into categories but just want to collect all the values.

```csharp
[Property]
public Property Reverse_Reverse_has_no_effect(int[] values)
{
    Func<bool> test = () =>
    {
        var list = new List<int>(values);
        list.Reverse();
        list.Reverse();
        return list.SequenceEqual(values);
    };

    return
        test
        .Collect($"List length: {values.Length}");
}
```

**Output**:
```
Ok, passed 100 tests.
6% "List length: 1".
4% "List length: 22".
4% "List length: 2".
⋯
```

### Combining Observations
You can use all of the observations together.

```csharp
[Property]
public Property Dividing_by_self_is_1(int x)
{
    Func<bool> test = () =>
    {
        var quotient = MyMath.Divide(x, x);
        return quotient == 1;
    };

    return
        test
        .When(x != 0)
        .Classify(x > 0, "Positive numbers")
        .Classify(x < 0, "Negative numbers")
        .Trivial(x == 1)
        .Collect($"Value: {x}");
}
```

**Output**
```
Ok, passed 100 tests.
5% "Value: -5", Negative numbers.
4% "Value: 4", Positive numbers.
⋯
1% "Value: 1", trivial, Positive numbers.
⋯
```

## Combined Properties
A test case can check more than one property.

```csharp
[Property]
public Property When_dividing(PositiveInt x, PositiveInt y)
{
    var quotient = MyMath.Divide(x.Get, y.Get);

    return
        (quotient <= x.Get)
            .Label("Quotient must be ≤ to dividend.")
        .And(quotient * y.Get == x.Get)
            .Label("Quotient × divisor = dividend");
}
```

This fails. The error message show the property's label.

**Output**:
```
Message:
    FsCheck.Xunit.PropertyFailedException :
    Falsifiable, after 8 tests (0 shrinks) (StdGen (1029087747,296805295)):
    Label of failing property: Quotient × divisor = dividend
    Original:
    (PositiveInt 1, PositiveInt 2)
```

# Generators, Shrinkers and Arbitrary Instances

FsCheck provides default generators for some often used types. You will have to define your own generator for new types you create. To create your own generator you can use the `Gen<T>` class and Linq methods.

Shrinkers are used to narrow down the failing test case given the initial random test case.

FsCheck uses `Arbitrary` to package a generator and shrinker for a type. You can define custom `Arbitrary` instances for you own types by defining static members that return an instance of `Arbitrary<'a>`. FsCheck organizes `Arbitrary` instances in a `<Type, Arbitrary>` dictionary.

## Generators

Generators are contracted from the `choose` function. `choose` picks a random value from an interval, with a uniform distribution.

```csharp
public Gen<T> ChooseFrom<T>(T[] list)
{
    return Gen
        .Choose(0, list.Length - 1)
        .Select(i => list[i]);
}
```

### Constant

`Gen.Constant<T>(T value)` always returns the same value.

```csharp
var generator = Gen.Constant(5);
```

### Choosing between alternatives

#### Equal probability

`Gen.OneOf<T>(params Gen<T>[] generators)` picks one of the generators with equal probability.

```csharp
var generator =
    Gen.OneOf(
        Gen.Constant("a"),
        Gen.Constant("b"));
```

#### Define distribution

`Gen.Frequency<T>(params Tuple<int, Gen<T>>[] weightedValues)` picks a one of the generators with weighted probability.

```csharp
var generator =
    Gen.Frequency(
        Tuple.Create(1, Gen.Constant("a")),
        Tuple.Create(2, Gen.Constant("b")));
```

### Test data size

Generators have an implicit size parameter. Testing starts with small test cases and progresses to larger test cases.

Generators can interpret the size parameter as they please or ignore it completely.

Size is accessed via the `Gen.Sized<T>(Func<int, Gen<T>> sizedGen)` function.

```csharp
var generator =
    Gen.Sized(size => Gen.Choose(0, size));
```

### Generating recursive data types

Recursive data types can be generated using `OneOf` or `Frequency` to choose between constructors.

```csharp
public static Gen<Tree> SafeTree()
{
    return Gen.Sized(size => TreeBuilder(size));

    Gen<Tree> TreeBuilder(int size)
    {
        if (size == 0)
            return Arb.Generate<int>().Select(i => (Tree)new Leaf(i));
        else
            return Gen.OneOf(
                Arb.Generate<int>()
                    .Select(i => (Tree)new Leaf(i)),
                Gen.Two(TreeBuilder(size / 2))
                    .Select(t => (Tree)new Branch(t.Item1, t.Item2)));
    }
}
```

### Generator functions

Apply
: Apply the given Gen function to the given generator, aka the applicative <*> operator
: `Gen<b> Apply<a, b>(Gen<FSharpFunc<a, b>> f, Gen<a> gn)`

Array2DOf
: Generates a 2D array.
: `Gen<a[,]> Array2DOf<a>(Gen<a> g)`
: `Gen<a[,]> Array2DOf<a>(int rows, int cols, Gen<a> g)`

ArrayOf
: Generates an array
: `Gen<a[]> ArrayOf<a>(int n, Gen<a> g)`
: `Gen<a[]> ArrayOf<a>(Gen<a> g)`

Choose
: Generates an integer between l and h, inclusive.
: `Gen<int> Choose(int l, int h)`

Collect
: Traverse the given enumerable/array into a generator to create generators.
: `Gen<IEnumerable<b>> Collect<a, b>(FSharpFunc<a, Gen<b>> f, IEnumerable<a> l)`
: `Gen<b[]> CollectToArray<a, b>(FSharpFunc<a, Gen<b>> f, params a[] xs)`
: `Gen<FSharpList<b>> CollectToList<a, b>(FSharpFunc<a, Gen<b>> f, IEnumerable<a> l)`

Constant
: Always generate the same instance v. See also fresh.
: `Gen<a> Constant<a>(a v)`

Elements
: Build a generator that randomly generates one of the values in the given non-empty seq.
: `Gen<a> Elements<a>(params a[] values)`
: `Gen<a> Elements<a>(IEnumerable<a> xs)`

Eval
: Generates a value of the give size with the given seed
: `a Eval<a>(int size, Random.StdGen seed, Gen<a> _arg1)`

Filter
: Generates a value that satisfies a predicate. This function keeps re-trying by increasing the size of the original generator ad infinitum. The `filter` function is an alias for the `where` function.
: `Gen<a> Filter<a>(FSharpFunc<a, bool> predicate, Gen<a> generator)`
: `Gen<a> Where<a>(FSharpFunc<a, bool> predicate, Gen<a> generator)`

TryFilter
:Tries to generate a value that satisfies a predicate. The `tryFilter` function is an alias for the `tryWhere` function. This function 'gives up' by generating None if the given original generator did not generate any values that satisfied the predicate, after trying to get values by increasing its size.
: `Gen<FSharpOption<a>> TryFilter<a>(FSharpFunc<a, bool> predicate, Gen<a> generator)`
: `Gen<FSharpOption<a>> TryWhere<a>(FSharpFunc<a, bool> predicate, Gen<a> generator)`

Tuple
: Build a generator that generates a tuple of the values generated by the given generator.
: `Gen<Tuple<a, a, a, a>> Four<a>(Gen<a> g)`
: `Gen<Tuple<a, a, a>> Three<a>(Gen<a> g)`
: `Gen<Tuple<a, a>> Two<a>(Gen<a> g)`

Frequency
: Build a generator that generates a value from one of the generators in the given non-empty seq, with given probabilities. The sum of the probabilities must be larger than zero.
: `Gen<a> Frequency<a>(params WeightAndValue<Gen<a>>[] weightedValues)`
: `Gen<a> Frequency<a>(params Tuple<int, Gen<a>>[] weightedValues)`
: `Gen<a> Frequency<a>(IEnumerable<Tuple<int, Gen<a>>> xs)`
: `Gen<a> Frequency<a>(IEnumerable<WeightAndValue<Gen<a>>> weightedValues)`

Fresh
: Generate a fresh instance every time the generator is called. Useful for mutable objects. See also constant.
: `Gen<a> Fresh<a>(FSharpFunc<Unit, a> fv)`
: `Gen<a> Fresh<a>(Func<a> fv)`

GrowingElements
: Build a generator that takes a non-empty sequence and randomly generates one of the values among an initial segment of that sequence. The size of this initial segment increases with the size parameter.
: `Gen<a> GrowingElements<a>(IEnumerable<a> xs)`

ListOf
: Generates a list of random/given length
: `Gen<FSharpList<a>> ListOf<a>(Gen<a> gn)`
: `Gen<FSharpList<a>> ListOf<a>(int n, Gen<a> arb)`

NonEmptyListOf
: Generates a non-empty list of random length. The maximum length depends on the size parameter.
: `Gen<FSharpList<a>> NonEmptyListOf<a>(Gen<a> gn)`

SubListOf
: Generates sublists of the given values
: `Gen<IList<a>> SubListOf<a>(IEnumerable<a> s)`
: `Gen<IList<a>> SubListOf<a>(params a[] s)`
: `Gen<FSharpList<a>> SubListOfToList<a>(IEnumerable<a> l)`

Map
: Apply the function f to the value in the generator, yielding a new generator.
: `Gen<b> Map<a, b>(FSharpFunc<a, b> f, Gen<a> gen)`

MapX
: Map the given function over values to a function over generators of those values.
: `Gen<c> Map2<a, b, c>(FSharpFunc<a, FSharpFunc<b, c>> f, Gen<a> a, Gen<b> b)`
: `Gen<d> Map3<a, b, c, d>(FSharpFunc<a, FSharpFunc<b, FSharpFunc<c, d>>> f, Gen<a> a, Gen<b> b, Gen<c> c)`
: `Gen<e> Map4<a, b, c, d, e>(FSharpFunc<a, FSharpFunc<b, FSharpFunc<c, FSharpFunc<d, e>>>> f, Gen<a> a, Gen<b> b, Gen<c> c, Gen<d> d)`
: `Gen<f> Map5<a, b, c, d, e, f>(FSharpFunc<a, FSharpFunc<b, FSharpFunc<c, FSharpFunc<d, FSharpFunc<e, f>>>>> f, Gen<a> a, Gen<b> b, Gen<c> c, Gen<d> d, Gen<e> e)`
: `Gen<g> Map6<a, b, c, d, e, f, g>(FSharpFunc<a, FSharpFunc<b, FSharpFunc<c, FSharpFunc<d, FSharpFunc<e, FSharpFunc<f, g>>>>>> f, Gen<a> a, Gen<b> b, Gen<c> c, Gen<d> d, Gen<e> e, Gen<f> g)`

OneOf
: Build a generator that generates a value from one of the given generators, with equal probability
: `Gen<a> OneOf<a>(IEnumerable<Gen<a>> gens)`
: `Gen<a> OneOf<a>(params Gen<a>[] generators)`

optionOf
: Generate an option value that is 'None' 1/8 of the time.
: `Gen<FSharpOption<a>> optionOf<a>(Gen<a> g)`

Piles
: Generates a random array of length k where the sum of all elements equals the given sum.
: `Gen<int[]> Piles(int k, int sum)`

Resize
: Override the current size of the test. resize n g invokes generator g with size parameter n.
: `Gen<a> Resize<a>(int newSize, Gen<a> _arg1)`

Sample
: Generates n values of the given size.
: `FSharpList<a> Sample<a>(int size, int n, Gen<a> generator)`

ScaleSize
: Modify a size using the given function before passing it to the given Gen.
: `Gen<a> ScaleSize<a>(FSharpFunc<int, int> f, Gen<a> g)`

Sequence
: Convert the given value generators into a generator of a sequence of values
: `Gen<IEnumerable<a>> Sequence<a>(IEnumerable<Gen<a>> generators)`
: `Gen<a[]> Sequence<a>(params Gen<a>[] generators)`

SequenceToList
: Sequence the given enumerable of generators into a generator of a list.
: `Gen<FSharpList<a>> SequenceToList<a>(IEnumerable<Gen<a>> l)`

Shuffle
: Generates a random permutation of the given sequence.
: `Gen<a[]> Shuffle<a>(IEnumerable<a> xs)`

Sized
: Obtain the current size
: `Gen<a> Sized<a>(FSharpFunc<int, Gen<a>> fgen)`
: `Gen<a> Sized<a>(Func<int, Gen<a>> sizedGen)`

Unzip
: Split a generator of tuples into a tuple of generators.
: `Tuple<Gen<a>, Gen<b>> Unzip<a, b>(Gen<Tuple<a, b>> g)`
: `Tuple<Gen<a>, Gen<b>, Gen<c>> Unzip<a, b, c>(Gen<Tuple<a, b, c>> g)`

Zip
: Combine generators into a generator of Tuples
: `Gen<Tuple<a, b>> Zip<a, b>(Gen<a> f, Gen<b> g)`
: `Gen<Tuple<a, b, c>> Zip<a, b, c>(Gen<a> f, Gen<b> g, Gen<c> h)`

## Shrinker

## Arbitrary

FsCheck uses `Arbitrary` to package a generator and shrinker for a type. You can define custom `Arbitrary` instances for you own types by defining static members that return an instance of `Arbitrary<'a>`.

```csharp
public class MyGenerators
{
    public static Gen<MyType> GenerateMyType()
    {
        return
            Gen
            .Sized(size =>
                Gen
                .Choose(0, size)
                .Select(value => new MyType() { AValue = value }));
    }

    public Arbitrary<MyType> MyTypes()
    {
        return Arb.From(GenerateMyType());
    }
}
```

FsCheck organizes `Arbitrary` instances in a `<Type, Arbitrary>` dictionary. To use the arbitrary generator you register it:

```csharp
Arb.Register<MyGenerators>();
```

### `Arb` methods

Convert
: Construct an Arbitrary instance for a type that can be mapped to and from another type (e.g. a wrapper), based on a Arbitrary instance for the source type and two mapping functions
:
: `Arbitrary<b> Convert<a, b>(FSharpFunc<a, b> convertTo, FSharpFunc<b, a> convertFrom, Arbitrary<a> a)`

Filter
: Return an Arbitrary instance that is a filtered version of an existing arbitrary instance. The generator uses Gen.suchThat, and the shrinks are filtered using Seq.filter with the given predicate.
: `Arbitrary<a> Filter<a>(FSharpFunc<a, bool> pred, Arbitrary<a> a)`

From
: Get the Arbitrary instance for the given type
: `Arbitrary<Value> From<Value>()`
: Construct an Arbitrary instance from a generator. Shrink is not supported for this type.
: `Arbitrary<Value> From<Value>(Gen<Value> gen)`
: Construct an Arbitrary instance from a generator and shrinker.
: `Arbitrary<Value> From<Value>(Gen<Value> gen, FSharpFunc<Value, IEnumerable<Value>> shrinker)`
: `Arbitrary<Value> From<Value>(Gen<Value> gen, Func<Value, IEnumerable<Value>> shrinker)`

MapFilter
: Return an Arbitrary instance that is a mapped and filtered version of an existing arbitrary instance. The generator uses Gen.map with the given mapper and then Gen.suchThat with the given predicate, and the shrinks are filtered using Seq.filter with the given predicate. This is sometimes useful if using just a filter would reduce the chance of getting a good value from the generator - and you can map the value instead. E.g. PositiveInt.
: `Arbitrary<a> MapFilter<a>(FSharpFunc<a, a> mapper, FSharpFunc<a, bool> pred, Arbitrary<a> a)`

Register
: Register the generators that are static members of the type
: `TypeClass.TypeClassComparison Register(Type t)`
: `TypeClass.TypeClassComparison Register<t>()`

Generate
: Return a generator
: `Gen<Value> Generate<Value>()`

Shrink
: Returns the immediate shrinks for the given value based on its type.
: `IEnumerable<Value> Shrink<Value>(Value a)`

shrinkNumber
: A generic shrinker that should work for most number-like types
: `IEnumerable<a> shrinkNumber<a, b, c, d>(a n)`

Default
: Type containing all the default `Arbitrary` instances as they are shipped and registered by FsCheck.
: `Arb.Defualt`

# Bibliography

#### [1]

Koen Claessen and John Hughes. **QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs**. In: Proceedings of the ACM SIGPLAN International Conference on Functional Programming, ICFP 46 (Jan. 2000). DOI: 10.1145/1988042.1988046.

#### [2]

Richard Hamlet. **Random Testing**. In: Encyclopedia of Software Engineering. Wiley, 1994,
pp. 970–978.

#### [3]

**FsCheck**. [https://fscheck.github.io/FsCheck/index.html](https://fscheck.github.io/FsCheck/index.html).

#### [4]
**Property-Based Testing with C#**. [https://www.codit.eu/blog/property-based-testing-with-c/?country_sel=be](https://www.codit.eu/blog/property-based-testing-with-c/?country_sel=be).