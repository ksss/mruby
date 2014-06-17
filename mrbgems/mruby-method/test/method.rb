assert 'demo' do
  class Interpreter
    attr_accessor :ret

    def do_a() ret << "there, "; end
    def do_d() ret << "Hello ";  end
    def do_e() ret << "!\n";     end
    def do_v() ret << "Dave";    end
    Dispatcher = {
      "a" => instance_method(:do_a),
      "d" => instance_method(:do_d),
      "e" => instance_method(:do_e),
      "v" => instance_method(:do_v)
    }
    def interpret(string)
      @ret = ""
      string.each_char {|b| Dispatcher[b].bind(self).call }
    end
  end

  interpreter = Interpreter.new
  interpreter.interpret('dave')
  assert_equal "Hello there, Dave!\n", interpreter.ret
end

assert 'arity' do
  Class.new {
    attr_accessor :done
    def initialize; @done = false; end
    def m0() end
    def m1(a) end
    def m2(a,b) end
    def mo3(*a) end

    def run
      assert_equal 0, method(:m0).arity
      assert_equal 1, method(:m1).arity
      assert_equal 2, method(:m2).arity
      assert_equal(-1, method(:mo3).arity)
      assert_equal(-1, method(:__send__).arity)
    end
  }.new.run
end

assert 'owner' do
  c = Class.new do
    def foo; end
  end
  assert_equal(c, c.instance_method(:foo).owner)
  c2 = Class.new(c)
  assert_equal(c, c2.instance_method(:foo).owner)
end

assert 'owner missing' do
  c = Class.new do
    def respond_to_missing?(name, bool)
      name == :foo
    end
  end
  c2 = Class.new(c)
  assert_equal(c, c.new.method(:foo).owner)
  assert_equal(c2, c2.new.method(:foo).owner)
end

assert 'receiver name owner' do
  o = Object.new
  def o.foo; end
  m = o.method(:foo)
  assert_equal(o, m.receiver)
  assert_equal(:foo, m.name)
  assert_equal(class << o; self; end, m.owner)
  assert_equal(:foo, m.unbind.name)
  assert_equal(class << o; self; end, m.unbind.owner)
end

assert 'unbind' do
  assert_equal(:derived, Derived.new.foo)
  um = Derived.new.method(:foo).unbind
  assert_instance_of(UnboundMethod, um)
  Derived.class_eval do
    def foo() :changed end
  end
  assert_equal(:changed, Derived.new.foo)
  assert_equal(:derived, um.bind(Derived.new).call)
  assert_raise(TypeError) do
    um.bind(Base.new)
  end
end
