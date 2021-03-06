require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "om"

describe "OM::XML::Term" do
  
  before(:each) do
    @test_name_part = OM::XML::Term.new(:namePart, {}).generate_xpath_queries!
    @test_volume = OM::XML::Term.new(:volume, :path=>"detail", :attributes=>{:type=>"volume"}, :default_content_path=>"number")
    @test_date = OM::XML::Term.new(:namePart, :attributes=>{:type=> "date"})
    @test_affiliation = OM::XML::Term.new(:affiliation)
    @test_role_code = OM::XML::Term.new(:roleTerm, :attributes=>{:type=>"code"})
  end
  
  describe '#new' do
    it "should set default values" do
      @test_name_part.namespace_prefix.should == "oxns"
    end
    it "should set path from mapper name if no path is provided" do
      @test_name_part.path.should == "namePart"
    end
    it "should populate the xpath values if no options are provided" do
      local_mapping = OM::XML::Term.new(:namePart)
      local_mapping.xpath_relative.should be_nil
      local_mapping.xpath.should be_nil
      local_mapping.xpath_constrained.should be_nil
    end
  end
  
  describe 'inner_xml' do
    it "should be a kind of Nokogiri::XML::Node" do
      pending
      @test_mapping.inner_xml.should be_kind_of(Nokogiri::XML::Node)
    end
  end
  
  describe '#from_node' do
    it "should create a mapper from a nokogiri node" do
      pending "probably should do this in the Builder"
      ng_builder = Nokogiri::XML::Builder.new do |xml|
        xml.mapper(:name=>"person", :path=>"name") {
          xml.attribute(:name=>"type", :value=>"personal")
          xml.mapper(:name=>"first_name", :path=>"namePart") {
            xml.attribute(:name=>"type", :value=>"given")
            xml.attribute(:name=>"another_attribute", :value=>"myval")
          }
        }
      end
      # node = Nokogiri::XML::Document.parse( '<mapper name="first_name" path="namePart"><attribute name="type" value="given"/><attribute name="another_attribute" value="myval"/></mapper>' ).root
      node = ng_builder.doc.root
      mapper = OM::XML::Term.from_node(node)
      mapper.name.should == :person
      mapper.path.should == "name"
      mapper.attributes.should == {:type=>"personal"}
      mapper.internal_xml.should == node
            
      child = mapper.children[:first_name]

      child.name.should == :first_name
      child.path.should == "namePart"
      child.attributes.should == {:type=>"given", :another_attribute=>"myval"}
      child.internal_xml.should == node.xpath("./mapper").first
    end
  end
  
  describe ".label" do
    it "should default to the mapper name with underscores converted to spaces"
  end
  
  describe ".retrieve_term" do
    it "should crawl down into mapper children to find the desired term" do
      mock_role = mock("mapper", :children =>{:text=>"the target"})
      mock_conference = mock("mapper", :children =>{:role=>mock_role})   
      @test_name_part.expects(:children).returns({:conference=>mock_conference})   
      @test_name_part.retrieve_term(:conference, :role, :text).should == "the target"
    end
    it "should return an empty hash if no term can be found" do
      @test_name_part.retrieve_term(:journal, :issue, :end_page).should == nil
    end
  end
  
  describe 'inner_xml' do
    it "should be a kind of Nokogiri::XML::Node" do
      pending
      @test_name_part.inner_xml.should be_kind_of(Nokogiri::XML::Node)
    end
  end
  
  describe "getters/setters" do
    it "should set the corresponding .settings value and return the current value" do
      [:path, :index_as, :required, :data_type, :variant_of, :path, :attributes, :default_content_path, :namespace_prefix].each do |method_name|
        @test_name_part.send(method_name.to_s+"=", "#{method_name.to_s}foo").should == "#{method_name.to_s}foo"
        @test_name_part.send(method_name).should == "#{method_name.to_s}foo"        
      end
    end
  end
  it "should have a .terminology attribute accessor" do
    @test_volume.should respond_to :terminology
    @test_volume.should respond_to :terminology=
  end
  describe ".ancestors" do
    it "should return an array of Terms that are the ancestors of the current object, ordered from the top/root of the hierarchy" do
      @test_volume.set_parent(@test_name_part)
      @test_volume.ancestors.should == [@test_name_part]
    end
  end
  describe ".parent" do
    it "should retrieve the immediate parent of the given object from the ancestors array" do
      # @test_name_part.expects(:ancestors).returns(["ancestor1","ancestor2","ancestor3"])
      @test_name_part.ancestors = ["ancestor1","ancestor2","ancestor3"]
      @test_name_part.parent.should == "ancestor3"
    end
  end
  describe ".children" do
    it "should return a hash of Terms that are the children of the current object, indexed by name" do
      @test_volume.add_child(@test_name_part)
      @test_volume.children[@test_name_part.name].should == @test_name_part
    end
  end
  describe ".retrieve_child" do
    it "should fetch the child identified by the given name" do
      @test_volume.add_child(@test_name_part)
      @test_volume.retrieve_child(@test_name_part.name).should == @test_volume.children[@test_name_part.name]
    end
  end
  describe ".set_parent" do
    it "should insert the mapper into the given parent" do
      @test_name_part.set_parent(@test_volume)
      @test_name_part.ancestors.should include(@test_volume)
      @test_volume.children[@test_name_part.name].should == @test_name_part
    end
  end
  describe ".add_child" do
    it "should insert the given mapper into the current mappers children" do
      @test_volume.add_child(@test_name_part)
      @test_volume.children[@test_name_part.name].should == @test_name_part
      @test_name_part.ancestors.should include(@test_volume)
    end
  end
  
  describe "generate_xpath_queries!" do
    it "should return the current object" do
      @test_name_part.generate_xpath_queries!.should == @test_name_part
    end
    it "should regenerate the xpath values" do      
      @test_volume.xpath_relative.should be_nil
      @test_volume.xpath.should be_nil
      @test_volume.xpath_constrained.should be_nil
      
      @test_volume.generate_xpath_queries!.should == @test_volume
      
      @test_volume.xpath_relative.should == 'oxns:detail[@type="volume"]'
      @test_volume.xpath.should == '//oxns:detail[@type="volume"]'
      @test_volume.xpath_constrained.should == '//oxns:detail[@type="volume" and contains(oxns:number, "#{constraint_value}")]'.gsub('"', '\"') 
    end
    it "should trigger update on any child objects" do
      mock_child = mock("child term")
      mock_child.expects(:generate_xpath_queries!).times(3)
      @test_name_part.expects(:children).returns({1=>mock_child, 2=>mock_child, 3=>mock_child})
      @test_name_part.generate_xpath_queries!
    end
  end
  
  describe "#xml_builder_template" do
    
    it "should generate a template call for passing into the builder block (assumes 'xml' as the argument for the block)" do
      @test_date.xml_builder_template.should == 'xml.namePart( \'#{builder_new_value}\', :type=>\'date\' )'
      @test_affiliation.xml_builder_template.should == 'xml.affiliation( \'#{builder_new_value}\' )'
    end
    it "should accept extra options" do
      marcrelator_role_xml_builder_template = 'xml.roleTerm( \'#{builder_new_value}\', :type=>\'code\', :authority=>\'marcrelator\' )'  
      @test_role_code.xml_builder_template(:attributes=>{"authority"=>"marcrelator"}).should == marcrelator_role_xml_builder_template
    end
    
    it "should work for nodes with default_content_path" do      
      @test_volume.xml_builder_template.should == "xml.detail( :type=>'volume' ) { xml.number( '\#{builder_new_value}' ) }"
    end
    
  end
  
end