/*
 * Messages.vala
 * This file is part of Wrote
 *
 * Copyright (C) 2012 - Stojan Dimitrovski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

namespace Wrote.Messages {

  public const string FILE_NOT_FOUND =
"""The file you tried to open does not seem to exist. Proceed by selecting
another one, or you can continue editing this file.""";

  public const string FILE_IS_DIRECTORY =
"""You tried to open what appears to be a directory. Please select a file or
continue editing this one.""";

  public const string LOAD_PERMISSION_DENIED =
"""It appears that you don't have the permission to read the file you asked to
open. Contact your system administrator to learn how to change this. You can now
continue editing this as a new file.""";

  public const string SAVE_PERMISSION_DENIED =
"""You don't seem to have the right permissions to save your document to that
location. Contact your system administrator to learn more about this. You can
now choose a different location to save your document, or continue editing it.""";

  public const string LOAD_ENCODING_CONVERSION_FAILED =
"""Reading the file as %s does not seem to be possible. Select a different
encoding for the file and try again, or continue editing this as a new file.""";

  public const string SAVE_ENCODING_CONVERSION_FAILED =
"""It does not seem to be possible to save your document to %s as it may contain
characters not supported by this encoding. Please select a different encoding
and try again.""";
}
