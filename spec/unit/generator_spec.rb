require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "om"

describe "OM::XML::Generator" do
  
  before(:all) do
    #ModsHelpers.name_("Beethoven, Ludwig van", :date=>"1770-1827", :role=>"creator")
    class GeneratorTest 
      
      include OM::XML::Container     
      include OM::XML::Properties
      include OM::XML::Generator      
      
      # Could add support for multiple root declarations.  
      #  For now, assume that any modsCollections have already been broken up and fed in as individual mods documents
      # root :mods_collection, :path=>"modsCollection", 
      #           :attributes=>[],
      #           :subelements => :mods
                     
      root_property :mods, "mods", "http://www.loc.gov/mods/v3", :attributes=>["id", "version"], :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd"          
                
                
      property :name_, :path=>"name", 
                  :attributes=>[:xlink, :lang, "xml:lang", :script, :transliteration, {:type=>["personal", "enumerated", "corporate"]} ],
                  :subelements=>["namePart", "displayForm", "affiliation", :role, "description"],
                  :default_content_path => "namePart",
                  :convenience_methods => {
                    :date => {:path=>"namePart", :attributes=>{:type=>"date"}},
                    :family_name => {:path=>"namePart", :attributes=>{:type=>"family"}},
                    :given_name => {:path=>"namePart", :attributes=>{:type=>"given"}},
                    :terms_of_address => {:path=>"namePart", :attributes=>{:type=>"termsOfAddress"}}
                  }
      property :person, :variant_of=>:name_, :attributes=>{:type=>"personal"}
      property :role, :path=>"role",
                  :parents=>[:name_],
                  :attributes=>[ { "type"=>["text", "code"] } , "authority"],
                  :default_content_path => "roleTerm"
                  
    end
        
  end
  
  before(:each) do
    @sample = GeneratorTest.from_xml( fixture( File.join("test_dummy_mods.xml") ) )
  end
  
  after(:all) do
    Object.send(:remove_const, :GeneratorTest)
  end
  
  describe '#generate' do
    it "should use the corresponding builder template(s) to generate the node" do
      GeneratorTest.generate(:mods, "foo").root.to_xml.should == "<mods>foo</mods>"
      # GeneratorTest.generate([:person,:role], "creator", {:attributes=>{"type"=>"code", "authority"=>"marcrelator"}}).root.to_xml.should == "<role authority=\"marcrelator\" type=\"code\">\n  <roleTerm>creator</roleTerm>\n</role>"
      generated_node = GeneratorTest.generate([:person,:role], "creator", {:attributes=>{"type"=>"code", "authority"=>"marcrelator"}})
      # generated_node.should have_node 'role[@authority="marcrelator"][@type="code"]' do
      #   with_node "roleTerm", "creator"
      # end
      generated_node.xpath('./role[@authority="marcrelator"][@type="code"]').xpath("./roleTerm").text.should == "creator"

    end
    it "should return Nokogiri Documents" do
      GeneratorTest.generate(:mods, "foo").class.should == Nokogiri::XML::Document
    end
  end
  
end