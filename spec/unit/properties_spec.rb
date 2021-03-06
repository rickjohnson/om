require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "om"

describe "OM::XML::Properties" do
  
  before(:all) do
    #ModsHelpers.name_("Beethoven, Ludwig van", :date=>"1770-1827", :role=>"creator")
    class FakeOxMods 

      include OM::XML::Container            
      include OM::XML::Properties      
      
      # Could add support for multiple root declarations.  
      #  For now, assume that any modsCollections have already been broken up and fed in as individual mods documents
      # root :mods_collection, :path=>"modsCollection", 
      #           :attributes=>[],
      #           :subelements => :mods
                
                  
      root_property :mods, "mods", "http://www.loc.gov/mods/v3", :attributes=>["id", "version"], :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd"          
      
      property :title_info, :path=>"titleInfo", 
                  :convenience_methods => {
                    :main_title => {:path=>"title"},
                    :language => {:path=>{:attribute=>"lang"}},                    
                  }
                
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
                  
      property :journal, :path=>'relatedItem', :attributes=>{:type=>"host"},
                  :subelements=>[:title_info, :origin_info, :issue],
                  :convenience_methods => {
                    :issn => {:path=>"identifier", :attributes=>{:type=>"issn"}},
                  }   

      property :issue, :path=>'part',
                  :subelements=>[:start_page, :end_page, :volume],
                  :convenience_methods => {
                    # :volume => {:path=>"detail", :attributes=>{:type=>"volume"}},
                    :level => {:path=>"detail", :attributes=>{:type=>"number"}, :default_content_path=>"number"},
                    # Hack to support provisional spot for start & end page (nesting was too deep for this version of OM)
                    :citation_start_page => {:path=>"pages", :attributes=>{:type=>"start"}},
                    :citation_end_page => {:path=>"pages", :attributes=>{:type=>"end"}},
                    :foo => {:path=>"foo", :attributes=>{:type=>"ness"}},
                    :publication_date => {:path=>"date"}
                  }
                  
      property :volume, :path=>"detail", :attributes=>{:type=>"volume"}, :subelements=>"number"
      
      property :start_page, :path=>"extent", :attributes=>{:unit=>"pages"}, :default_content_path => "start"
      property :end_page, :path=>"extent", :attributes=>{:unit=>"pages"}, :default_content_path => "end"    
    end
    
    class FakeOtherOx < Nokogiri::XML::Document
      
      include OM::XML::Properties
      # extend OX::ClassMethods
      
      root_property :other, "other", "http://www.foo.com"        
      
    end
        
  end
  
  before(:each) do
    @fixturemods = FakeOxMods.from_xml( fixture( File.join("CBF_MODS", "ARS0025_016.xml") ) )
  end
  
  after(:all) do
    Object.send(:remove_const, :FakeOxMods)
  end
  
  describe "#new" do
    it "should set up namespaces" do
      @fixturemods.ox_namespaces.should == {"oxns"=>"http://www.loc.gov/mods/v3", "xmlns:ns2"=>"http://www.w3.org/1999/xlink", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", "xmlns:ns3"=>"http://www.loc.gov/mods/v3"}
    end
  end
  
  describe "#root_property" do
    it "should initialize root_property class attributes without attributes bleeding over to other OX classes" do
      FakeOxMods.root_property_ref.should == :mods
      FakeOxMods.root_config.should == {:ref=>:mods, :path=>"mods", :namespace=>"http://www.loc.gov/mods/v3", :attributes=>["id", "version"], :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd"}
      FakeOxMods.ox_namespaces.should == {"oxns"=>"http://www.loc.gov/mods/v3"}
      
      FakeOtherOx.root_property_ref.should == :other
      FakeOtherOx.root_config.should == {:namespace=>"http://www.foo.com", :path=>"other", :ref=>:other}
    end
    it "should add a corresponding entry into the properties hash" do
      FakeOxMods.property_info_for(FakeOxMods.root_property_ref).should == {:schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd", :xpath_relative=>"oxns:mods", :path=>"mods", :xpath_constrained=>"//oxns:mods[contains(\\\"\#{constraint_value}\\\")]", :xpath=>"//oxns:mods", :ref=>:mods, :convenience_methods=>{}, :attributes=>["id", "version"]}
      FakeOxMods.builder_template(FakeOxMods.root_property_ref).should == "xml.mods( '\#{builder_new_value}' )"
    end
  end
  
  describe "#property" do
    
    it "fails gracefully if you try to look up nodes for an undefined property" do
      @fixturemods.lookup(:nobody_home).should == []
    end
  
    it "constructs xpath queries for finding properties" do
      FakeOxMods.properties[:name_][:xpath].should == '//oxns:name'   
      FakeOxMods.properties[:name_][:xpath_relative].should == 'oxns:name'               
                  
      FakeOxMods.properties[:person][:xpath].should == '//oxns:name[@type="personal"]'
      FakeOxMods.properties[:person][:xpath_relative].should == 'oxns:name[@type="personal"]'
    end
    
    it "constructs templates for value-driven searches" do
      FakeOxMods.properties[:name_][:xpath_constrained].should == '//oxns:name[contains(oxns:namePart, "#{constraint_value}")]'.gsub('"', '\"')
      FakeOxMods.properties[:person][:xpath_constrained].should == '//oxns:name[@type="personal" and contains(oxns:namePart, "#{constraint_value}")]'.gsub('"', '\"')
      
      # Example of how you could use these templates:
      constraint_value = "SAMPLE CONSTRAINT VALUE"
      constrained_query = eval( '"' + FakeOxMods.properties[:person][:xpath_constrained] + '"' )
      constrained_query.should == '//oxns:name[@type="personal" and contains(oxns:namePart, "SAMPLE CONSTRAINT VALUE")]'
    end
    
    it "constructs xpath queries & templates for convenience methods" do
      FakeOxMods.properties[:name_][:convenience_methods][:date][:xpath].should == '//oxns:name/oxns:namePart[@type="date"]'
      FakeOxMods.properties[:name_][:convenience_methods][:date][:xpath_relative].should == 'oxns:namePart[@type="date"]'
      FakeOxMods.properties[:name_][:convenience_methods][:date][:xpath_constrained].should == '//oxns:name[contains(oxns:namePart[@type="date"], "#{constraint_value}")]'.gsub('"', '\"')      
            
      FakeOxMods.properties[:person][:convenience_methods][:date][:xpath].should == '//oxns:name[@type="personal"]/oxns:namePart[@type="date"]'
      FakeOxMods.properties[:person][:convenience_methods][:date][:xpath_relative].should == 'oxns:namePart[@type="date"]'      
      FakeOxMods.properties[:person][:convenience_methods][:date][:xpath_constrained].should == '//oxns:name[@type="personal" and contains(oxns:namePart[@type="date"], "#{constraint_value}")]'.gsub('"', '\"')
          
    end
    
    it "constructs xpath queries & templates for subelements too" do
      FakeOxMods.properties[:person][:convenience_methods][:displayForm][:xpath].should == '//oxns:name[@type="personal"]/oxns:displayForm'
      FakeOxMods.properties[:person][:convenience_methods][:displayForm][:xpath_relative].should == 'oxns:displayForm'      
      FakeOxMods.properties[:person][:convenience_methods][:displayForm][:xpath_constrained].should == '//oxns:name[@type="personal" and contains(oxns:displayForm, "#{constraint_value}")]'.gsub('"', '\"')
    end
    
    it "supports subelements that are specified as separate properties" do
      FakeOxMods.properties[:name_][:convenience_methods][:role][:xpath].should == '//oxns:name/oxns:role'
      FakeOxMods.properties[:name_][:convenience_methods][:role][:xpath_relative].should == 'oxns:role'
      FakeOxMods.properties[:name_][:convenience_methods][:role][:xpath_constrained].should == '//oxns:name[contains(oxns:role/oxns:roleTerm, "#{constraint_value}")]'.gsub('"', '\"')
    end
    
    it "supports treating attributes as properties" do
      FakeOxMods.properties[:title_info][:convenience_methods][:language][:xpath].should == '//oxns:titleInfo/@lang'
      FakeOxMods.properties[:title_info][:convenience_methods][:language][:xpath_relative].should == '@lang'
      FakeOxMods.properties[:title_info][:convenience_methods][:language][:xpath_constrained].should == '//oxns:titleInfo[contains(@lang, "#{constraint_value}")]'.gsub('"', '\"')
    end
    
    it "should support deep nesting of properties" do
      pending "requires property method to be recursive"
      
      FakeOxMods.properties[:journal][:convenience_methods][:issue][:convenience_methods][:volume].should == {:xpath_constrained=>"//oxns:part[contains(oxns:detail[@type=\\\"volume\\\"], \\\"\#{constraint_value}\\\")]", :path=>"detail", :attributes=>{:type=>"volume"}, :xpath=>"//oxns:part/oxns:detail[@type=\"volume\"]", :xpath_relative=>"oxns:detail[@type=\"volume\"]"}
      prop_info = FakeOxMods.property_info_for([:journal, :issue, :volume])
      prop_info[:xpath_constrained].should == "//oxns:part[contains(oxns:detail[@type=\\\"volume\\\"], \\\"\#{constraint_value}\\\")]"
      prop_info[:xpath].should == "//oxns:part/oxns:detail[@type=\"volume\"]"
      prop_info[:xpath_relative].should == "oxns:detail[@type=\"volume\"]"
    end
    
    it "should support even deeper nesting of properties" do
      pending "requires property method to be recursive"
      
      FakeOxMods.properties[:journal][:convenience_methods][:issue][:convenience_methods][:start_page].should == {:xpath_constrained=>"//oxns:part[contains(oxns:detail[@type=\\\"volume\\\"], \\\"\#{constraint_value}\\\")]", :path=>"detail", :attributes=>{:type=>"volume"}, :xpath=>"//oxns:part/oxns:detail[@type=\"volume\"]", :xpath_relative=>"oxns:detail[@type=\"volume\"]"}
      FakeOxMods.property_info_for([:journal, :issue, :end_page]).should == ""      
    end
    
    it "should not overwrite default property info when adding a variant property" do      
      FakeOxMods.properties[:name_].should_not equal(FakeOxMods.properties[:person])
      FakeOxMods.properties[:name_][:convenience_methods].should_not equal(FakeOxMods.properties[:person][:convenience_methods])

      FakeOxMods.properties[:name_][:xpath].should_not == FakeOxMods.properties[:person][:xpath]
      FakeOxMods.properties[:name_][:convenience_methods][:date][:xpath_constrained].should_not == FakeOxMods.properties[:person][:convenience_methods][:date][:xpath_constrained]
    end
  
  end
  
  describe ".lookup"  do
    
    it "uses the generated xpath queries" do
      @fixturemods.ng_xml.expects(:xpath).with('//oxns:name[@type="personal"]', @fixturemods.ox_namespaces)
      @fixturemods.lookup(:person)
      
      @fixturemods.ng_xml.expects(:xpath).with('//oxns:name[@type="personal" and contains(oxns:namePart, "Beethoven, Ludwig van")]', @fixturemods.ox_namespaces)
      @fixturemods.lookup(:person, "Beethoven, Ludwig van")
      
      @fixturemods.ng_xml.expects(:xpath).with('//oxns:name[@type="personal" and contains(oxns:namePart[@type="date"], "2010")]', @fixturemods.ox_namespaces)
      @fixturemods.lookup(:person, :date=>"2010")
      
      @fixturemods.ng_xml.expects(:xpath).with('//oxns:name[@type="personal" and contains(oxns:role/oxns:roleTerm, "donor")]', @fixturemods.ox_namespaces)
      @fixturemods.lookup(:person, :role=>"donor")
      
      # 
      # This is the way we want to move towards... (currently implementing part of this in accessor_constrained_xpath)
      # @fixturemods.ng_xml.expects(:xpath).with('//oxns:relatedItem/oxns:identifier[@type=\'issn\'] and contains("123-ABC-44567")]', @fixturemods.ox_namespaces)
      # @fixturemods.lookup([:journal, :issn], "123-ABC-44567")
      
    end
  
  end
  
  describe ".xpath_query_for" do

    it "retrieves the generated xpath query to match your desires" do    
      @fixturemods.xpath_query_for(:person).should == '//oxns:name[@type="personal"]'
          
      @fixturemods.xpath_query_for(:person, "Beethoven, Ludwig van").should == '//oxns:name[@type="personal" and contains(oxns:namePart, "Beethoven, Ludwig van")]'
          
      @fixturemods.xpath_query_for(:person, :date=>"2010").should == '//oxns:name[@type="personal" and contains(oxns:namePart[@type="date"], "2010")]'
          
      @fixturemods.xpath_query_for(:person, :role=>"donor").should == '//oxns:name[@type="personal" and contains(oxns:role/oxns:roleTerm, "donor")]'
          
      @fixturemods.xpath_query_for([:person,:date]).should == '//oxns:name[@type="personal"]/oxns:namePart[@type="date"]'
          
      @fixturemods.xpath_query_for([:person,:date], "2010").should == '//oxns:name[@type="personal" and contains(oxns:namePart[@type="date"], "2010")]'
    end
    
    it "parrots any strings back to you (in case you already have an xpath query)" do
      @fixturemods.xpath_query_for('//oxns:name[@type="personal"]/oxns:namePart[@type="date"]').should == '//oxns:name[@type="personal"]/oxns:namePart[@type="date"]'
    end
    
  end
  
  describe "#generate_xpath" do
    it "should generate an xpath query from the options in the provided hash and should support generating xpaths with constraint values" do
      opts1 = {:path=>"name", :default_content_path=>"namePart"}
      opts2 = {:path=>"originInfo"}
      opts3 = {:path=>["name", "namePart"]}
      FakeOxMods.generate_xpath( opts1 ).should == '//oxns:name'
      FakeOxMods.generate_xpath( opts1, :constraints=>:default ).should == '//oxns:name[contains(oxns:namePart, "#{constraint_value}")]'
      FakeOxMods.generate_xpath( opts2, :constraints=>:default ).should == '//oxns:originInfo[contains("#{constraint_value}")]'

      FakeOxMods.generate_xpath( opts1, :variations=>{:attributes=>{:type=>"personal"}} ).should == '//oxns:name[@type="personal"]'
      FakeOxMods.generate_xpath( opts1, :variations=>{:attributes=>{:type=>"personal"}}, :constraints=>:default ).should == '//oxns:name[@type="personal" and contains(oxns:namePart, "#{constraint_value}")]'
             
      FakeOxMods.generate_xpath( opts1, :constraints=>{:path=>"namePart", :attributes=>{:type=>"date"}} ).should == '//oxns:name[contains(oxns:namePart[@type="date"], "#{constraint_value}")]'
      FakeOxMods.generate_xpath( opts1, :constraints=>{:path=>"namePart", :attributes=>{:type=>"date"}}, :variations=>{:attributes=>{:type=>"personal"}} ).should == '//oxns:name[@type="personal" and contains(oxns:namePart[@type="date"], "#{constraint_value}")]'
      FakeOxMods.generate_xpath(FakeOxMods.properties[:person], :variations=>{:attributes=>{:type=>"personal"}}, :constraints=>{:path=>"role", :default_content_path=>"roleTerm"}, :subelement_of=>":person").should == '//oxns:name[@type="personal" and contains(oxns:role/oxns:roleTerm, "#{constraint_value}")]'
      
      FakeOxMods.generate_xpath(opts1,  :variations=>{:attributes=>{:type=>"personal"}, :subelement_path=>"displayForm" } ).should == '//oxns:name[@type="personal"]/oxns:displayForm'
      FakeOxMods.generate_xpath(opts1,  :variations=>{:attributes=>{:type=>"personal"}}, :constraints=>{:path=>"displayForm"} ).should == '//oxns:name[@type="personal" and contains(oxns:displayForm, "#{constraint_value}")]'
      FakeOxMods.generate_xpath(opts1,  :variations=>{:attributes=>{:type=>"personal"}, :subelement_path=>["role", "roleTerm"] } ).should == '//oxns:name[@type="personal"]/oxns:role/oxns:roleTerm'
      
      FakeOxMods.generate_xpath( opts3, :variations=>{:attributes=>{:type=>"date"}} ).should == '//oxns:name/oxns:namePart[@type="date"]'
      FakeOxMods.generate_xpath( opts3, :variations=>{:attributes=>{:type=>"date"}}, :constraints=>:default ).should == '//oxns:name/oxns:namePart[@type="date" and contains("#{constraint_value}")]'

      FakeOxMods.generate_xpath( {:path=>["relatedItem", "identifier"]}, :variations=>{:attributes=>{:type=>"issn"}}, :constraints=>:default ).should == '//oxns:relatedItem/oxns:identifier[@type="issn" and contains("#{constraint_value}")]'

    end
    
    
    it "should support relative paths" do
      relative_opts = {:path=>"namePart"}
      FakeOxMods.generate_xpath( relative_opts, :variations=>{:attributes=>{:type=>"date"}}, :relative=>true).should == 'oxns:namePart[@type="date"]'
    end
    
    it "should work with real properties hashes" do
      FakeOxMods.generate_xpath(FakeOxMods.properties[:person], :variations=>FakeOxMods.properties[:person]).should == "//oxns:name[@type=\"personal\"]"
      FakeOxMods.generate_xpath(FakeOxMods.properties[:person], :variations=>FakeOxMods.properties[:person], :constraints=>{:path=>"role", :default_content_path=>"roleTerm"}, :subelement_of=>":person").should == '//oxns:name[@type="personal" and contains(oxns:role/oxns:roleTerm, "#{constraint_value}")]'
      date_hash = FakeOxMods.properties[:person][:convenience_methods][:date]
      FakeOxMods.generate_xpath( date_hash, :variations=>date_hash, :relative=>true ).should == 'oxns:namePart[@type="date"]'
    end
    
    it "should support custom templates" do
      opts = {:path=>"name", :default_content_path=>"namePart"}
      FakeOxMods.generate_xpath( opts, :template=>'/#{prefix}:sampleNode/#{prefix}:#{path}[contains(#{default_content_path}, \":::constraint_value:::\")]' ).should == '/oxns:sampleNode/oxns:name[contains(namePart, "#{constraint_value}")]'      
    end
  end
  
  describe "#builder_template" do
    
    it "should generate a template call for passing into the builder block (assumes 'xml' as the argument for the block)" do
      FakeOxMods.builder_template([:person,:date]).should == 'xml.namePart( \'#{builder_new_value}\', :type=>\'date\' )'
      FakeOxMods.builder_template([:name_,:affiliation]).should == 'xml.affiliation( \'#{builder_new_value}\' )'
      
      simple_role_builder_template = 'xml.role( :type=>\'text\' ) { xml.roleTerm( \'#{builder_new_value}\' ) }'  
      FakeOxMods.builder_template([:role]).should == simple_role_builder_template
      FakeOxMods.builder_template([:person,:role]).should == simple_role_builder_template
      
      marcrelator_role_builder_template = 'xml.role( :type=>\'code\', :authority=>\'marcrelator\' ) { xml.roleTerm( \'#{builder_new_value}\' ) }'  
      FakeOxMods.builder_template([:role], {:attributes=>{"type"=>"code", "authority"=>"marcrelator"}} ).should == marcrelator_role_builder_template
      FakeOxMods.builder_template([:person,:role], {:attributes=>{"type"=>"code", "authority"=>"marcrelator"}} ).should == marcrelator_role_builder_template      
    end
    
    it "should work with deeply nested properties" do      
      FakeOxMods.builder_template([:issue, :volume]).should == "xml.detail( '\#{builder_new_value}', :type=>'volume' )"
      FakeOxMods.builder_template([:volume, :number]).should == "xml.number( '\#{builder_new_value}' )"
      FakeOxMods.builder_template([:journal, :issue, :level]).should == "xml.detail( :type=>'number' ) { xml.number( '\#{builder_new_value}' ) }"
      FakeOxMods.builder_template([:journal, :issue, :volume]).should == "xml.detail( '\#{builder_new_value}', :type=>'volume' )"
      FakeOxMods.builder_template([:journal, :issue, :volume, :number]).should == "xml.number( '\#{builder_new_value}' )"
      FakeOxMods.builder_template([:journal, :issue, :start_page]).should == "xml.extent( :unit=>'pages' ) { xml.start( '\#{builder_new_value}' ) }"
    end
    
  end
  
  describe "#applicable_attributes" do
    it "returns a Hash where all of the values are strings" do
      FakeOxMods.send(:applicable_attributes, {:type=>"date"} ).should == {:type=>"date"} 
      FakeOxMods.send(:applicable_attributes, ["authority", {:type=>["text","code"]}] ).should == {:type=>"text"} 
    end
  end
   
end