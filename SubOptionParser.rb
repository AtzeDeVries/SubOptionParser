class SubOptionParser

  def initialize(options = Hash.new)
    require 'optparse'
    @subs = Hash.new
    @opts = options
    @header = "This function has the following subcommands. Run\n#{$0} <subcommand> --help for information about a subcommand\n\n"
  end

  def header(header)
   @header = header
  end

  def sub(name,desc='')
    @subs[name] = desc
    instance_variable_set("@#{name}", Array.new)
    s = OptionParser.new
    s.banner = "Usage: #{$0} #{name} [options]"
    instance_variable_get("@#{name}") << s
  end

  def suboption(name,key,*options)
    raise "#{name} is not a defined sub argument" unless @subs.include? name
    raise "need at least 1 argument for options " if options.length == 0
    setoptions(name,key,*options)
  end

  def globaloption(key,*options)
    raise "need at least 1 argument for options " if options.length == 0
    @subs.each do |su,desc|
      setoptions(su,key,*options)
    end
  end

  def listsubs
    @subs.each do |sub,desc|
      puts "#{sub}\t\t#{desc}"
    end
  end

  def parse!
    if ARGV.length == 0
      puts @header
      self.listsubs
      exit
    elsif ARGV[0].include? '-'
      puts 'suboption needs to be at first position'
      exit
    elsif not @subs.include? ARGV[0]
       puts "suboption '#{ARGV[0]}' does not exist"
       exit
    else
      @opts[:sub] = ARGV[0]
      instance_variable_get("@#{ARGV.shift}")[0].parse!
      puts ARGV
      @opts
    end
  end

  def setoptions(name,key,*options)
    s = instance_variable_get("@#{name}")[0]
    case options.length
    when 1
      s.on(options[0]) do |o| @opts[key] = o end
    when 2
      s.on(options[0],options[1]) do |o| @opts[key] = o end
    when 3
      s.on(options[0],options[1],options[2]) do |o| @opts[key] = o end
    when 4
      s.on(options[0],options[1],options[2],options[3]) do |o| @opts[key] = o end
    else
      raise "to many options"
    end
  end

  private :setoptions

end
