---
title: "Repositories: The Public Interface"
layout: post
---

The previous entry covered how Chassis works internally. This is the
precursor to the public interface. This post is about how data moves
between the large application, class facades, and underlying repo &
persistence implementation.

Let's start at the bottom and work our way up. `Chassis::Repo`
includes a simple public interface. It looks like this:

* `Chassis::Repo#all(klass, id)`
* `Chassis::Repo#find(klass, id)`
* `Chassis::Repo#save(record)`
* `Chassis::Repo#delete(record)`
* `Chassis::Repo#first(klass)`
* `Chassis::Repo#last(klass)`
* `Chassis::Repo#query(klass, selector)`
* `Chassis::Repo#graph_query(klass, selector)`
* `Chassis::Repo#sample(klass)`
* `Chassis::Repo#empty?(klass)`
* `Chassis::Repo#count(klass)`
* `Chassis::Repo#clear`

`Chassis::Repo` includes a few more methods built on these primitives,
but these methods drive all communication with the underlying
implementation. You can see most methods take a `klass` argument.
These methods are for interacting with collections. The other methods
are for instances. The implementation can use the `klass` to decide
what to do.

`Chassis::Repo::Delegation` defines the same methods but without the
`klass` argument. It replaces `klass` with an `object_class` method.
`object_class` looks at the class name and deduces the domain class
from there. Extending `PostRepo` with `Chassis::Record::Delegation`
defines a `find` method. `find` looks like this:

```ruby
def find(id)
  repo.find object_class, id
end
```

`repo` is `Chassis::Repo.default` by default. `PostRepo` may redefine
`repo` if the operations are handled by different repository instance.

This makes creating class specific facades much easier because they
just build on the public interface. The class specific facades define
all the application specific queries. Here's an example.

```ruby
class PostRepo
  extend Chassis::Repo::Delegation

  FindPostsByAuthor = Struct.new(:author)

  class << self
    def written_by(author)
      query FindPostsByAuthor.new(author)
    end
  end
end
```

Class specific facades may also redefine the methods listed in public
interface section to add whatever they see fit. They may coerce IDs
from string to integers. They may add caching to a set of calls.
Defining query methods is the most common use case in my experience.

Working with repository and persisted objects is straight forward. A
persisteable object must respond to `id` and `id=`. That is the only
requirement. Here is some code to give you an idea of what it feels
like to work with these objects.

```ruby
class Post
  attr_accessor :id, :title, :text
end

repo = Chassis::Repo.default

repo.empty? Post #=> true

post = Post.new
post.title = 'Such Repos'
post.text = 'Very wow. Much design.'

repo.save post

post.id #=> 1

found_post = repo.find Post, post.id
found_post == post #=> true (no difference between objects in memory)

post.title = 'Such updates'
post.text = 'Very easy. Wow'

repo.save post

repo.find(post, post.id).text #=> 'Very easy. Wow.'

class PostRepo
  extend Chassis::Repo::Delegation
end

post = PostRepo.find post.id
post.text #=> 'Very Easy. Wow'

PostRepo.all #=> [post]
# etc

PostRepo.delete post
PostRepo.empty? #=> true
```

This concludes the basic CRUD examples. The public interface should be
easy enough to explore from here on out. I do not want this post to go
long because the next few posts cover implementing parts of the public
API in depth. The next post is on implementing queries.
