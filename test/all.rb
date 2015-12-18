scope "generic routing" do
  peru = proc { |key|
    case key
    when :population
      30_400_000
    when :area
      1_285_216
    else
      nil
    end
  }

  @words = {
    "peru" => peru,
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

  setup do
    Hart.new(@words)
  end

  test do |h|
    definition = h.call(:population, "/peru")
    assert_equal definition, 30400000

    definition = h.call(:define, "/c/o/d")
    assert_equal definition, "A husk; a pod; as, a peascod."

    definition = h.call(:define, "/c/o/d/a")
    assert_equal definition, "Concluding passage of a piece or movement."

    definition = h.call(:define, "/c/o/d/e")
    assert_equal definition, "System of rules relating to one subject."

    definition = h.call(:define, "/c/o/d/e/c")
    assert_equal definition, "Device that compresses and decompresses data."

    definition = h.call(:define, "/c/o/d/e/x")
    assert_equal definition, "A book; a manuscript."

    definition = h.call(:define, "/c/o/d/e/r")
    assert_equal definition, nil
  end
end

scope "routing HTTP requests" do

  class HartWrapper
    PATH_INFO      = "PATH_INFO".freeze
    REQUEST_METHOD = "REQUEST_METHOD".freeze

    def initialize(hart)
      @hart = hart
    end

    def call(env)
      @hart.call(env.fetch(REQUEST_METHOD), env.fetch(PATH_INFO))
    end
  end

  @routes = {
    default: [404, {}, [""]],

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

  app = HartWrapper.new(Hart.new(@routes))

  setup do
    Driver.new(app)
  end

  test "path + verb" do |f|
    f.get("/foo/bar")
    assert_equal 200, f.last_response.status
    assert_equal "GET /foo/bar", f.last_response.body

    f.put("/foo/bar")
    assert_equal 200, f.last_response.status
    assert_equal "PUT /foo/bar", f.last_response.body
  end

  test "verbs match only on root" do |f|
    f.get("/bar/baz/foo")
    assert_equal "", f.last_response.body
    assert_equal 404, f.last_response.status
  end

  test "root" do |f|
    f.get("/")
    assert_equal "GET /", f.last_response.body
    assert_equal 200, f.last_response.status
  end

  test "captures" do |f|
    f.get("/users/42")
    assert_equal "GET /users/42", f.last_response.body
    assert_equal 200, f.last_response.status
  end
end
