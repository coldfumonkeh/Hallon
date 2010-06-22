# require extension file
require File.expand_path('./../../ext/hallon', __FILE__)
require 'singleton'

# libspotify[https://developer.spotify.com/en/libspotify/overview/] bindings for Ruby!
module Hallon
  # Internally used by Hallon. It provides an #each method for classes providing #at and #length.
  module Eachable
    include Enumerable

    # Iterates through each element in the class including this module.
    def each(&block)
      acc = Array.new

      length.times do |i|
        obj = self.at(i)
        obj = yield obj if block_given?
        acc.push obj
      end

      return acc
    end
  end
  
  # Thrown by Hallon::Session on Spotify errors.
  class Error < StandardError
  end
  
  # Main workhorse of Hallon!
  class Session
    include Singleton # Spotify APIv4
    
    # Acessor for ::new.
    def self.instance(*args)
      if @__instance__ and args.length > 0
        raise ArgumentError, "session has already been initialized"
      end

      @__instance__ ||= new *args
      
      at_exit do
        @__instance__.logout if @__instance__.logged_in?
      end
      
      return @__instance__
    end
  end
  
  # Contains the users playlists.
  class PlaylistContainer
    include Hallon::Eachable
    
    # Removes playlists that are equal to playlist. Returns nil of 
    # playlist is not found.
    def delete(playlist)
      
      found = nil
      index = 0
      while index < length
        unless playlist == at(index)
          index = index + 1
          next
        end
        
        found = delete_at(index)
      end
      
      return found
    end
    
    # Alias for #length.
    def size
      return length
    end
  end
  
  # Playlists are created from the PlaylistContainer.
  class Playlist
    include Hallon::Eachable
    
    private_class_method :new
    
    # Remove all Tracks.
    def clear!
      remove (0...length).to_a
    end
    
    # Remove <code>count</code> tracks from <code>index</code>.
    def delete_at(index, count = 1)
      remove (index...index + count).to_a
    end
    
    # Insert Track(s) at the end of the playlist.
    def push(*tracks)
      insert length, *tracks
    end
    
    # Insert Track(s) at the beginning of the playlist.
    def unshift(*tracks)
      insert 0, *tracks
    end
    
    # Alias for #push.
    def <<(*tracks)
      push *tracks
    end
    
    # Compares two playlists. They are equal if they share the same link.
    def ==(obj)
      return false unless obj.respond_to? :to_link
      return to_link == obj.to_link
    end
    
    # Alias for #length.
    def size
      return length
    end
  end
  
  # Object for acting on Spotify URIs.
  class Link
    
    # Return the ID for this link.
    def id
      return to_str.split(':').last
    end
    
    # Compares one Spotify URI with another — Link or String.
    def ==(other)
      return to_str == other.to_str
    end
  end
  
  # A class for acting on Tracks. You create a Track by using Link#to_obj.
  class Track
    private_class_method :new
  end
  
  # A regex to match Spotify URIs
  URI = /(spotify:(?:
    (?:artist|album|track|user:[^:]+:playlist):[a-zA-Z0-9]+
    |user:[^:]+
    |search:(?:[-\w$\.+!*'(),]+|%[a-fA-F0-9]{2})+
    ))
  /x
end