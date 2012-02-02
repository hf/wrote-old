/*
 * Status.vala
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

using Gtk;

using Wrote;

public class Wrote.Status: Gtk.Label {
  public weak Wrote.Document document { get; construct set; }

  private uint push_timeout = 0;

  construct {
    this.document.buffer.notify["words"].connect(() => {
      if (this.push_timeout == 0) {
        this.normal();
      }
    });

    this.document.buffer.notify["chars"].connect(() => {
      if (this.push_timeout == 0) {
        this.normal();
      }
    });

    this.normal();

    this.override_color(Gtk.StateFlags.NORMAL, Wrote.Theme.COLOR);
  }

  public Status(Wrote.Document d) {
    Object(document: d);
  }

  public void push(string text, uint timeout = 3000) {
    this.label = text;

    if (this.push_timeout != 0) {
      Source.remove(this.push_timeout);
    }

    this.push_timeout = Timeout.add(timeout, () => {
      this.normal();

      return false;
    });
  }

  public void normal() {
    if (this.push_timeout != 0) {
      Source.remove(this.push_timeout);
      this.push_timeout = 0;
    }

    this.label = "%d Words / %d Characters".printf(
      this.document.buffer.words,
      this.document.buffer.chars);
  }
}
