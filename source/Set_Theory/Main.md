---
title: Set theory
lang: en
toc-title: Contents
---

# Set theory

| Expression | Description               |  
|------------|---------------------------|
| $a \in A$ | $a$ is element of set $A$ |
| $\emptyset$ | empty set |
| $A \subseteq B$ | $A$ is subset of $B$. Every element of $A$ is in $B$ |
| $A = B \iff A \subseteq B; B \subseteq A$ | |
| $A \cup B$ | Union of $A$ and $B$. Elements in $A$ or $B$ |
| $A \cap B$ | Intersection of $A$ and $B$. Elements in $A$ and $B$ |
| $A - B$    | Difference of $A$ and $B$. Elements of $A$ not in $B$ |

## Relations

A binary relation $R$ on a set $A$ is a set of ordered pairs of elements of $A$, that is, a subset of $A \times A$.

$$R = \{ \dots,(a_i, a_j), \dots \} : a_i, a_j \in A$$
$$R \subseteq A \times A$$

| Relation type | Description |
|---------------|-------------|
| Reflexive     | $\forall a \in A : (a,a) \in R$ |
| Symmetric     | $(b,a) \in R \rightarrow (a,b) \in R$ |
| Transitive    | $(a,c) \in R \rightarrow (a,b) \in R; (b,c) \in R$ |
| Equivalence   | $R$ is Reflexive, Symmetric, and Transitive |

## Functions

A (1-ary) function on a set $A$ is a binary relation $F$ on $A$ such that for every a∈A there is exactly one pair (a,b)∈F.

$$ F:A \rightarrow B \ \Rightarrow \forall a \in A \exists! (a,b) \in F$$
$$ F(a) = b $$

$$ G \circ F \Rightarrow \ G \circ F = \{ \forall a_i \in A : (a_i,G(F(a_i))) \} : F:A \rightarrow B; \ G:B \rightarrow C;  $$

## Sets and formulas

Given formula $\varphi (x,y_1,…,y_n)$ and sets $A,B_1,\dots,B_n$. The set of all elements of $A$ that satisfy the formula $\varphi (x,B_1,…,B_n)$ is $\{a \in A : \varphi(a,B_1,\dots, B_n)\}$.

$$\emptyset = \{ a \in A:a \neq a\}$$
$$A=\{a \in A:a=a\}$$
$$A−B=\{a \in A:a \notin B\}$$
$$A \cap B=\{a \in A:a \in B\}$$
