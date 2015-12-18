Hart
====

Hash router

Description
-----------

Hart is a generic routing library that walks a hash and detects
matches according to a given pair of verb and path arguments.

Usage
-----

A basic example would look like this:

```ruby
words = {
  "c" => {
    "o" => {
      "d" => {
        define: "A husk; a pod; as, a peascod.",

        "a" => {
          define: "Concluding passage of a piece or movement."
        },

        "e" => {
          define: "System of rules relating to one subject.",

          "c" => {
            define: "Device that compresses and decompresses data."
          },

          "x" => {
            define: "A book; a manuscript."
          }
        }
      }
    }
  }
}

h = Hart.new(words)
h.call(:define, "/c/o/d")     #=> "A husk; a pod; as, a peascod."
h.call(:define, "/c/o/d/e")   #=> "System of rules relating to one subject."
h.call(:define, "/c/o/d/e/r") #=> nil
```

The `call` method accepts two arguments: a verb, which must be a
symbol, and a path, which must be a string in the form `"/a/b/c"`.

It is possible to define more than one verb per element:

```ruby
countries = {
  "argentina" => {
    population: 43_417_000,
    area: 2_780_400,
  },

  "france" => {
    population: 66_200_000,
    area: 640_679,
  }
}

h = Hart.new(countries)
h.call(:population, "/argentina") #=> 43417000
h.call(:population, "/france")    #=> 66200000
h.call(:area,       "/argentina") #=>  2780400
h.call(:area,       "/france")    #=>   640679
```

The default value for a miss can be configured as follows:

```ruby
countries[:default] = "Country not found."
```

After adding that key to the previous example, any miss will return
the string `"Country not found."`.

```ruby
h.call(:population, "/foobar") #=> "Country not found."
```

The value of each entry can be anything that responds to `[](key)`.
For instance, a `proc` could be used:

```ruby
countries["peru"] = proc { |key|
  case key
  when :population
    30_400_000
  when :area
    1_285_216
  else
    nil
  end
}

h.call(:population, "/peru") #=> 30400000
```

If the special symbol `:id` is present as an element, it will match
any path segment in that position, given that no other matches
occurred.

```ruby
countries[:id] = proc { |key|
  "No information about #{key}"
}

h.call(:area, "/foobar") #=> "No information about foobar"
```

The next example combines all the concepts explained so far, and
shows how to match HTTP requests based on `REQUEST_METHOD` and
`PATH_INFO`.

```ruby
routes = {
  default: [404, {}, ["Not Found"]],

  GET: [200, {}, ["GET /"]],

  "foo" => {
    "bar" => {
      GET: [200, {}, ["GET /foo/bar"]],
      PUT: [200, {}, ["PUT /foo/bar"]],
    }
  },

  "users" => {
    GET: [200, {}, ["GET /posts"]],

    id: proc { |id|
      {
        GET: [200, {}, ["GET /users/#{id}"]],
      }
    }
  }
}

h = Hart.new(routes)
h.call(:GET, "/foo/bar")  #=> [200, {}, ["GET /foo/bar"]]
h.call(:PUT, "/foo/bar")  #=> [200, {}, ["PUT /foo/bar"]]
h.call(:GET, "/users/42") #=> [200, {}, ["GET /users/42"]]
h.call(:GET, "/baz")      #=> [404, {}, ["Not Found"]]
```

API
---

`call`: Accepts two arguments: a verb, which must be a symbol, and
a path, which must be a string in the form `"/a/b/c"`.

Installation
------------

```
$ gem install hart
```
