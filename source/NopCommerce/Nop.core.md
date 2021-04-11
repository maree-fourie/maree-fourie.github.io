# ASP.NET Core MVC

```mermaid
graph LR
    User((User))
    style User fill:#f9f,stroke:#333,stroke-width:4px

    Model
    View
    Controller      

    User -->|request| Controller
    User -->|looks at| View
    Controller -->|perform user actions| Model
    Controller -->|retrieve results of queries| Model
    Controller -->|chooses| View
    Controller -->|provides Model data| View
    
```

```puml
@startdot
digraph G {
    A -> B
    B -> C
    C-> A
}
@enddot
```


```puml

class BaseEntity
interface ISoftDeletedEntity
interface ISlugSupported
interface IStoreMappingSupported
interface ISettings

package "Affiliate Collections" {
    class Affiliate extends BaseEntity
    class Affiliate implements ISoftDeletedEntity
}

package "Blogs Collections" {
    class BlogComment extends BaseEntity
    class BlogPostTag
    class BlogSettings implements ISettings
    class BlogPost extends BaseEntity
    class BlogPost implements ISlugSupported
    class BlogPost implements IStoreMappingSupported
    class BlogCommentApprovedEvent
}
```
