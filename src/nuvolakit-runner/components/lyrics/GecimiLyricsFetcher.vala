/*
 * Copyright 2020 xcffl <xcffl@protonmail.com>
 * Copyright 2020 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace Nuvola {
/**
 * Lyric fetcher for [[http://doc.gecimi.com/en/latest/|Gecimi (Lyrics Fans) Lyrics]].
 * Mainly Chinese and English lyrics.
 */
public class GecimiLyricsFetcher : GLib.Object, LyricsFetcher {
    public Soup.Session session {get; construct set;}
    /**
     * URL format of Gecimi Lyrics
     */
    private const string SONG_API = "https://gecimi.com/api/lyric/%s/%s";

    public GecimiLyricsFetcher (Soup.Session session) {
        GLib.Object(session: session);
    }

    /**
     * {@inheritDoc}
     */
    public async string fetch_lyrics (string artist, string song) throws LyricsError {
        /* Fetch lrc list */
        Soup.Message request;
        string url = SONG_API.printf(song, artist);

        request = new Soup.Message("GET", url);

        SourceFunc callback = fetch_lyrics.callback;
        session.queue_message(request, () => {
            Idle.add((owned) callback);
        });
        yield;

        string response = ( string ) request.response_body.flatten().data;
        if (request.status_code != 200 || response == "") {
            throw new LyricsError.NOT_FOUND(@"Song $song was not found on Gecimi Lyrics");
        }

        /* Get lrc content */
        string lrc_url = get_lrc_url(response);
        if (lrc_url == "") {
            throw new LyricsError.NOT_FOUND(@"Song $song was not found on Gecimi Lyrics");
        }
        request = new Soup.Message("GET", lrc_url);

        callback = fetch_lyrics.callback;
        session.queue_message(request, () => {
            Idle.add((owned) callback);
        });
        yield;

        response = ( string ) request.response_body.flatten().data;
        if (request.status_code != 200 || response == "") {
            throw new LyricsError.NOT_FOUND(@"Song $song was not found on Gecimi Lyrics");
        }

        return response;
    }

    private string get_lrc_url (string response) throws LyricsError {
        try {
            string url;
            if (Drt.JsonParser.load_object(response).dotget_string("result.0.lrc", out url)) {
                return url;
            }
            throw new LyricsError.NOT_FOUND("No lyrics in response.");
        } catch (Drt.JsonError e) {
            throw new LyricsError.PARSE_FAILED("Failed to parse response: %s", e.message);
        }
    }
}
} // namespace Nuvola
