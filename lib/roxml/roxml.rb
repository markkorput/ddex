module ROXML module ClassMethods module Operations
  
  def from_xml_v2(data, *initialization_args)
    xml = XML::Node.from(data)

    opts = initialization_args.extract_options!

    new(*initialization_args).tap do |inst|
      inst.roxml_references = roxml_attrs.map {|attr| attr.to_ref(inst) }

      inst.roxml_references.each do |ref|
        if opts[:validate] == false
          begin
            value = ref.value_in(xml)
            inst.respond_to?(ref.opts.setter) \
              ? inst.send(ref.opts.setter, value) \
              : inst.instance_variable_set(ref.opts.instance_variable_name, value)
          rescue RequiredElementMissing => e
            # do nothing, jsut skipped the value setting
          end
        else
          value = ref.value_in(xml)
          inst.respond_to?(ref.opts.setter) \
            ? inst.send(ref.opts.setter, value) \
            : inst.instance_variable_set(ref.opts.instance_variable_name, value)
        end
      end
      inst.send(:after_parse) if inst.respond_to?(:after_parse, true)
    end
  rescue ArgumentError => e
    raise e, e.message + " for class #{self}"
  end # of def from_xml

end end end