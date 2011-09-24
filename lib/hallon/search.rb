# coding: utf-8
module Hallon
  # Search allows you to search Spotify for tracks, albums
  # and artists, just like in the client.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__search.html
  class Search < Base
    include Observable

    # Construct a new search with given query.
    #
    # @param [String] query search query
    # @param [Hash] options additional search options
    # @option options [#to_i] :tracks (25) max number of tracks you want in result
    # @option options [#to_i] :albums (25) max number of albums you want in result
    # @option options [#to_i] :artists (25) max number of artists you want in result
    # @option options [#to_i] :tracks_offset (0) offset of tracks in search result
    # @option options [#to_i] :albums_offset (0) offset of albums in search result
    # @option options [#to_i] :artists_offset (0) offset of artists in search result
    # @see http://developer.spotify.com/en/libspotify/docs/group__search.html#gacf0b5e902e27d46ef8b1f40e332766df
    def initialize(query, options = {})
      o = {
        :tracks  => 25,
        :albums  => 25,
        :artists => 25,
        :tracks_offset  => 0,
        :albums_offset  => 0,
        :artists_offset => 0
      }.merge(options)

      @callback = proc { trigger(:load) }
      pointer   = Spotify.search_create(session.pointer, query, o[:tracks_offset].to_i, o[:tracks].to_i, o[:albums_offset].to_i, o[:albums].to_i, o[:artists_offset].to_i, o[:artists].to_i, @callback, nil)
      @pointer  = Spotify::Pointer.new(pointer, :search, false)
    end

    # @return [Boolean] true if the search has been fully loaded
    def loaded?
      Spotify.search_is_loaded(@pointer)
    end

    # @return [Symbol] error status
    def error
      Spotify.search_error(@pointer)
    end

    # @return [String] search query this search was created with
    def query
      Spotify.search_query(@pointer)
    end

    # @return [String] “did you mean?” suggestion for current search
    def did_you_mean
      Spotify.search_did_you_mean(@pointer)
    end

    # @return [Enumerator<Track>] enumerate over all tracks in the search result
    def tracks
      size = Spotify.search_num_tracks(@pointer)
      Enumerator.new(size) do |i|
        track = Spotify.search_track(@pointer, i)
        Track.new(track) unless track.null?
      end
    end

    # @return [Integer] total tracks available for this search query
    def total_tracks
      Spotify.search_total_tracks(@pointer)
    end

    # @return [Enumerator<Album>] enumerate over all albums in the search result
    def albums
      size  = Spotify.search_num_albums(@pointer)
      Enumerator.new(size) do |i|
        album = Spotify.search_album(@pointer, i)
        Album.new(album) unless album.null?
      end
    end

    # @return [Integer] total tracks available for this search query
    def total_albums
      Spotify.search_total_albums(@pointer)
    end

    # @return [Enumerator<Artist>] enumerate over all artists in the search result
    def artists
      size = Spotify.search_num_artists(@pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.search_artist(@pointer, i)
        Artist.new(artist) unless artist.null?
      end
    end

    # @return [Integer] total tracks available for this search query
    def total_artists
      Spotify.search_total_artists(@pointer)
    end
  end
end