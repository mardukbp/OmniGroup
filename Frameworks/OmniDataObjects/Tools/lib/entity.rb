module OmniDataObjects
  # TODO: Validate the name doesn't start with "ODO".  Make sure metadata table does.
  class Entity < Base
    attr_reader :model, :name, :instance_class, :properties, :abstract, :header_file

    def initialize(model, name, options = {})
      @model = model
      @name = name
      @instance_class = options[:instance_class] || "#{model.name}#{name}"
      @properties = []
      @abstract = options[:abstract]
    end

    def property_named(name)
      properties.find {|p| p.name == name}
    end

    def add_property(p)
      fail "Entity '#{name}' already has a property named '#{p.name}'" if property_named(p.name)
      fail "Adding property to the wrong entity" if p.entity != self
      properties << p
    end

    def process
      STDERR.print "Processing entity #{name}\n" if Options.debug
      properties.sort! {|a,b| a.name <=> b.name}
      properties.each {|p| p.process}
    end

    def validate
      STDERR.print "Validating entity #{name}\n" if Options.debug
      properties.each {|p| p.validate}
      
      primary_keys = properties.select {|p| Attribute === p && p.primary}
      fail "Exactly one primary key expected in #{name}, but #{primary_keys.size} found." if primary_keys.size != 1
    end

    def objcTypeName
      "Entity"
    end
    def keyName
      "#{model.name}#{name}#{objcTypeName}Name"
    end
    def varName
      "#{name}"
    end
    def statementKey(k)
      "@\"#{k.to_s}:#{name}\""
    end
    
    def category_name
      "#{model.name}Properties"
    end
    
    def header_file_name
      "#{instance_class}-#{category_name}.h"
    end

    def header_file(fs)    
      # Put the property definitions and string constants in their own header, assuming the main header written by the developer will import them.
      fs.make_if(header_file_name)
    end
    
    def emitDeclaration(fp)
      # All our properties are dynamic, which is the default.  Emit declarations for them.
      class_names = Array.new
      properties.each {|p| p.add_class_names(class_names)}
      class_names.uniq.sort.each {|c|
        fp.h << "@class #{c};\n"
      }
      
      fp.h << "@interface #{instance_class} (#{category_name})\n"
      begin
        properties.each {|p|
          p.emitInterface(fp.h)
        }
      end
      fp.h << "@end\n"
      fp.h.br
      return if abstract # Don't want the global for the entity name
      super
    end

    def emitDefinition(fp)
      return if abstract # Don't want the global for the entity name
      super
    end

    def emitCreation(f)
      f << "    ODOEntity *#{varName} = ODOEntityCreate(#{keyName}, #{statementKey(:I)}, #{statementKey(:U)}, #{statementKey(:D)}, #{statementKey(:PK)},\n"
      f << "    @\"#{instance_class}\",\n"
      
      # All properties
      f << "    [NSArray arrayWithObjects:"
      properties.each {|p| f << "#{p.varName}, " }
      f << "nil]);\n"

    end
    def emitBinding(f)
      f << "    ODOEntityBind(#{varName}, model);\n"
    end
  end
end