require "database/abstract"

class DirDatabase < AbstractEncDatabase

    def initialize( conf, debug )
        super( 'dir', conf, debug )
		STDERR.puts "DEBUG #{__FILE__}/#{__LINE__}: Using directory based host lookup : "+ @config.key( 'dir.db' ) if( @debug )
    end
        
    ## Scan the enc directory for a pattern file
    def search( pattern )
    	return nil if ! pattern
        return nil if ! @config.key?( 'dir.db' )

        dir = @config.key( 'dir.db' )
    	filelist = Array.new()
    	
    	if Dir.exists?( dir )
    		Dir.foreach( dir ) do |filename| 
    			if(  filename.match( /^\./ ) )
    				next
    			end	
    
    			if( /^#{pattern}#{JSON_ENDING}$/.match( filename ) )
    				filelist.push( filename )
    			end
    		end
    		
    	else
    		
    		raise ArgumentError, "ERROR #{__FILE__}/#{__LINE__}: Could not find directory to scan #{dir}"+"\n"
    		
    	end

    
    	return filelist
    end
    


    def load_profile( name )
        return nil if ! name
        return nil if ! @config.key?( 'dir.db' )
    
    
        if( ! /\.json/.match( name ) )
            name += JSON_ENDING
        end
        
    	## 
    	filename = @config.key( 'dir.db' )+"/"+name
    	if( File.exists?( filename ) )		
    		## Lets open it and parse it into a config object (hash)
    		begin
    
    			nodedata = JSON.load( File.open( filename ) )
    			if( @config != nil and nodedata != nil and nodedata.key?("include") )
    				include_profile = nodedata["include"]
    				
    				self.load_profile( include_profile ).each do |k,v|
    					if( ! nodedata.key?( k ) )
    						nodedata[k] = v
    					end
    				end
    				
    				STDERR.puts "DEBUG #{__FILE__}/#{__LINE__}: Including #{include_profile}" if( @debug )
    				nodedata.delete( "include" )
    			end
    			return nodedata
    			
    		rescue => error  ## Catching everything this time, no need to be picky
    			raise ArgumentError, "ERROR #{__FILE__}/#{__LINE__}: #{error}"+"\n"
    		end
    	else
    
    		raise ArgumentError,  "ERROR #{__FILE__}/#{__LINE__}: Could not find config file #{filename}"+"\n"
        
    	end
        
        
        
    end
    
end