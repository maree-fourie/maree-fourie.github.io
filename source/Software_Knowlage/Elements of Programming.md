# Elements of Programming

```mermaid
graph LR
    main((Elements of Programming))

    m0[Foundations]
    m1[Transformations and Their Orbits]
    m2[Associative Operations]
    m3[Linear Orderings]
    m4[Ordered Algebraic Structures]
    m5[Iterators]
    m6[Coordinate Structures]
    m7[Coordinates with Mutable Successors]
    m8[Copying]
    m9[Rearrangements]
    m10[Partition and Merging]
    m11[Composite Objects]

    M1([Algorithms on collections<br/>Algorithms on memory])
    M2([Algorithms on mathematical values])
    M3([Collections as objects])

    main --> M2
    M2 --> m0
    M2 --> m1
    M2 --> m2
    M2 --> m3
    M2 --> m4
    main --> M1
    M1 --> m5
    M1 --> m6
    M1 --> m7
    M1 --> m8
    M1 --> m9
    M1 --> m10
    
    n1(Partition)
    n2(Balanced Reduction)
    n3(Merging)
    m10 --> n1
    m10 --> n2
    m10 --> n3

    main --> M3
    M3 --> m11
```

## Categories of ideas

|  | Abstract | Concrete |
|--|--|--|
| Entity | An individual thing that is eternal and unchangeable | An individual thing that comes into and out of existence in space and time |