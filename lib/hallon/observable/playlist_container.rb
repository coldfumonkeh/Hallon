module Hallon::Observable
  module PlaylistContainer
    include Hallon::Observable

    # @example listening to this event
    #   playlist_container.on(:playlist_added) do |playlist, position, container|
    #     puts playlist.name + " added at #{position}."
    #   end
    #
    # @yield [playlist, position, self] playlist_added
    # @yieldparam [Playlist] playlist
    # @yieldparam [Integer] position
    # @yieldparam [PlaylistContainer] self
    def playlist_added_callback(pointer, playlist, position, userdata)
      playlist = Spotify::Pointer.new(playlist, :playlist, true)
      trigger(:playlist_added, Hallon::Playlist.new(playlist), position)
    end

    # @example listening to this event
    #   playlist_container.on(:playlist_removed) do |playlist, position, container|
    #     puts playlist.name + " removed from #{position}."
    #   end
    #
    # @yield [playlist, position, self] playlist_removed
    # @yieldparam [Playlist] playlist
    # @yieldparam [Integer] position
    # @yieldparam [PlaylistContainer] self
    def playlist_removed_callback(pointer, playlist, position, userdata)
      playlist = Spotify::Pointer.new(playlist, :playlist, true)
      trigger(:playlist_removed, Hallon::Playlist.new(playlist), position)
    end

    # @example listening to this event
    #   playlist_container.on(:playlist_moved) do |playlist, position, new_position, container|
    #     puts "moved #{playlist.name} from #{position} to #{new_position}"
    #   end
    #
    # @yield [playlist, position, new_position, self] playlist_moved
    # @yieldparam [Playlist] playlist
    # @yieldparam [Integer] position
    # @yieldparam [Integer] new_position
    # @yieldparam [PlaylistContainer] self
    def playlist_moved_callback(pointer, playlist, position, new_position, userdata)
      playlist = Spotify::Pointer.new(playlist, :playlist, true)
      trigger(:playlist_moved, Hallon::Playlist.new(playlist), position, new_position)
    end

    # @example listening to this event
    #   playlist_container.on(:container_loaded) do |container|
    #     puts "#{container.name} loaded!"
    #   end
    #
    # @yield [self] container_loaded
    # @yieldparam [PlaylistContainer] self
    def container_loaded_callback(pointer, userdata)
      trigger(:container_loaded)
    end
  end
end
