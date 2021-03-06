class OM::XML::NamedTermProxy
  
  attr_accessor :proxy_pointer, :name, :terminology
  
  include OM::TreeNode
  
  # Creates a Named Proxy that points to another term in the Terminology.
  # Unlike regular terms, NamedTermProxy requires you to provide a reference to the containing Terminology.
  # This is to ensure that it will always be able to look up the term that it's referencing.
  # @param [Symbol] name of the proxy term
  # @param [Array] proxy_pointer that points to the Term we're proxying
  # @param [OM::XML::Terminology] terminology that this Term is being built for
  # @param [Hash] opts additional Term options
  def initialize(name, proxy_pointer, terminology, opts={})
    opts = {:namespace_prefix=>"oxns", :ancestors=>[], :children=>{}}.merge(opts)
    [:children, :ancestors].each do |accessor_name|
      instance_variable_set("@#{accessor_name}", opts.fetch(accessor_name, nil) )     
    end
    @terminology = terminology
    @name = name
    @proxy_pointer = proxy_pointer
  end
  
  def proxied_term
    if self.parent.nil?
      self.terminology.retrieve_term(*self.proxy_pointer)
    else
      self.parent.retrieve_term(*self.proxy_pointer)
    end
  end
  
  # do nothing -- this is to prevent errors when the parent term calls generate_xpath_queries! on its children
  def generate_xpath_queries!
    # do nothing
  end
  
  # A proxy term can never serve as the root term of a Terminology.
  # Explicitly setting is_root_term? to return false to support proxies that are _at_ the root of the Terminology but aren't _the_ root term.
  def is_root_term?
    return false
  end
  
  def method_missing
  end
  
  # Any unknown method calls will be proxied to the proxied term
  def method_missing method, *args, &block 
    if args.empty?
      return self.proxied_term.send(method)
    else
      return self.proxied_term.send(method, args)
    end
  end
  
end