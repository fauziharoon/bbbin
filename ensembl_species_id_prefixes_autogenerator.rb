#!/usr/bin/env ruby

# Auto-generate the species prefixes for Ensembl, using the Ruby Ensembl API, and getting the 
# species-specific prefixes from the Ensembl database and dumping them (caching them) into
# ensembl_species_id_prefixes_autogenerated.rb



require 'rubygems'
require 'ensembl'
require 'pp'
require 'date'

CACHE_FILENAME = File.join(File.dirname(__FILE__),'ensembl_species_id_prefixes_autogenerated.rb')
ensembl_version = 63#Ensembl::ENSEMBL_RELEASE #Sometimes this is behind the times
puts "Using Ensembl version #{ensembl_version}"

# Module to connect to the production database to get a list of species
# and species IDs. This may be incorporated into the main Ruby Ensembl
# API in the future.
module Ensembl
  module Production
    class DBConnection < Ensembl::DBRegistry::Base
      self.abstract_class = true
      self.pluralize_table_names = false

      def self.connect(release = Ensembl::ENSEMBL_RELEASE, args = {})
        database = "ensembl_production_#{release}"
        self.generic_connect(nil,nil, release,{:database => database})
      end
    end # Core::DBConnection

    class Species < DBConnection
      set_primary_key 'species_id'
    end
  end # Production

  class SpeciesPrefixExtractor
    def initialize(ensembl_version=nil)
      @@species_info = nil
      @@ensembl_version = ensembl_version
    end
    
    def [](db_name)
      Ensembl::SpeciesPrefixExtractor.cache
      @@species_info[db_name]
    end

    def infos
      Ensembl::SpeciesPrefixExtractor.cache
      @@species_info
    end

    def self.cache(species_ensembl_version=nil)
      species_ensembl_version ||= @@ensembl_version
      return nil unless @@species_info.nil?
      
      # A hash of species db_names to SpeciesInformation objects
      @@species_info = {}

      # Get the list of species, db_name and common_names for each of species
      Ensembl::Production::Species.all.each do |sp|
        info = SpeciesInformation.new
        info.db_name = sp.db_name
        info.common_name = sp.common_name
        @@species_info[sp.db_name] = info
      end

      # Get the prefix information, which are in each of the individual databases
      @@species_info.each do |db_name, info|
        # next unless db_name == 'oreochromus_niloticus'
        $stderr.puts db_name
        con = Ensembl::Core::DBConnection.connect(db_name, species_ensembl_version)
        unless con.current_database
          warn "No connection could be established for #{db_name}, so no prefix is being recorded"
          next
        end
        prefix = Ensembl::Core::Meta.first(:conditions => ['meta_key = ?','species.stable_id_prefix'])
        @@species_info[db_name].prefix = prefix.meta_value unless prefix.nil?
      end
      nil
    end

    class SpeciesInformation
      attr_accessor :common_name, :db_name, :prefix
    end

  end

end # Ensembl

Ensembl::Production::DBConnection.connect(ensembl_version)
ex = Ensembl::SpeciesPrefixExtractor.new(ensembl_version)
hash = {}
ex.infos.collect do |db_name, info|
  unless info.prefix.nil?
    hash[info.prefix] = [info.common_name, db_name]
  end
end

# Dump them into the file now that they are downloaded from Ensembl.
dump = File.open(CACHE_FILENAME,'w')
dump.puts "# This file is autogenerate by ensembl_species_id_prefixes_autogenerator.rb - DO NOT MODIFY DIRECTLY!"
dump.print <<END
module Bio
  class Ensembl
    # Auto-generated #{Date.today.to_s} for Ensembl version #{ensembl_version}
    ENSEMBL_SPECIES_HASH = 
END

dump.puts '    {'

hash.each do |key, array|
  dump.puts "    '#{key}' => [#{array.collect{|a| "'#{a.gsub(/\'/,'')}'"}.join(",")}],"
end
dump.puts '    }'
dump.puts <<ENDA
  end
end
ENDA
dump.puts
dump.close


# Test that it works
$stderr.print "Testing it works by requiring it from Ruby.."
require CACHE_FILENAME
$stderr.puts " appears to work from Ruby. All good."


