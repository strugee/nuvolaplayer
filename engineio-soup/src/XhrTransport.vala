/*
 * Copyright 2016-2018 Jiří Janoušek <janousek.jiri@gmail.com>
 * -> Engine.io-soup - the Vala/libsoup port of the Engine.io library
 *
 * Copyright 2014 Guillermo Rauch <guillermo@learnboost.com>
 * -> The original JavaScript Engine.io library
 * -> https://github.com/socketio/engine.io
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * 'Software'), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
namespace Engineio {


public class XhrTransport: PollingTransport
{
    public XhrTransport(Request request)
    {
        base(request);
    }

    public override async void handle_request(Request request, Response response)
    {
        if (request.method == "OPTIONS")
        {
            headers_requested(request, response.headers);
            response.headers["Access-Control-Allow-Headers"] = "Content-Type";
            response.status_code = 200;
            response.end(null);
        }
        else
        {
            yield base.handle_request(request, response);
        }
    }

    protected override void on_headers_requested(Request request, HashTable<string, string> headers)
    {
        var origin = request.headers.get_one("origin");
        if (origin != null)
        {
            headers["Access-Control-Allow-Credentials"] = "true";
            headers["Access-Control-Allow-Origin"] = origin;
        }
        else
        {
            headers["Access-Control-Allow-Origin"] = "*";
        }
        base.on_headers_requested(request, headers);
    }
}

} // namespace Engineio
