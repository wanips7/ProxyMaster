unit uConst;

interface

{$REGION 'Licence'}
(*****************************************************************************

  Copyright (c) 2024 Ivan
  https://github.com/wanips7/ProxyMaster

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

******************************************************************************)
{$ENDREGION}

uses
  uTypes, uProxy;

const
  APP_VERSION = '1.0.0';
  SETTINGS_FILE_NAME = 'settings.ini';
  DATABASE_FILE_NAME = 'database.db';
  IP_GEO_FILE_NAME = 'GeoLite2-City.mmdb';
  CHECKER_RESULTS_FOLDER = 'Checked results';
  GRABBER_RESULTS_FOLDER = 'Grabbed results';

const
  PROXY_PROTOCOL_STRING: array [TProxy.TProtocol] of string =
    ('-', 'Http(s)', 'Socks4', 'Socks5');
  ANONIMOUS_LEVEL_STRING: array [TAnonymityLevel] of string =
    ('-', 'Transparent', 'Anonymous', 'Elite');
  RUNNING_STATUS_STRING: array[Boolean] of string = ('not running', 'running');

implementation

end.
