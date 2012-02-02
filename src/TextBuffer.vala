/*
 * TextBuffer.vala
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

// TODO: detect movement with move cursor signal on text view...

public class Wrote.TextBuffer: Gtk.TextBuffer {

  [CCode(notify = false)]
  public int32 words { get; private set; default = 0; }

  public int32 chars {
    get {
      return (int32) this.get_char_count();
    }
  }

  construct {
    this.set_modified(true);

    this.changed.connect(() => {
      this.notify_property("chars");
    });
  }

  public void reset() {
    this.words = 0;
    this.notify_property("words");
  }

  public override void delete_range(Gtk.TextIter start, Gtk.TextIter end) {
    int length = end.get_offset() - start.get_offset();

    Gtk.TextIter j = start;
    Gtk.TextIter i = end;

    bool changed_words = false;

    /* Single keypress deletion works like so:
     *  - Lorem [i]psum dolor sit amet. -= 0
     *  - Lorem [a] ipsum dolor sit amet. -= 1
     *  - Lorem ipsum[ ]dolor sit amet. -= 1
     */

    // TODO: Efficient counting by halving.

    if (length == 1) {
      if ((start.starts_word() && end.ends_word()) ||
          (start.ends_word() && end.starts_word())) {
        this.words--;
        changed_words = true;
      }
    } else if (length == this.get_char_count()) {
      this.reset();
    } else {

      /*
        Possible selections:
          * IN:  Lorem ips[um dolor s]it amet. == -1
            OUT: Lorem ipsum[ dolor] sit amet

          * IN:  Lorem ipsum [dolor si]t amet. == -1
            OUT: Lorem ipsum [dolor] sit amet.

          * IN:  Lorem ip[sum dolor] sit amet. == -1
            OUT: Lorem ipsum[ dolor] sit amet.

          * IN:  Lorem [ipsum dolor] sit amet. == -2
            OUT: Lorem [ipsum dolor] sit amet.
      */

      if (j.inside_word()) {
        j.forward_word_end();

        while (!j.starts_word() && j.forward_char());
      }

      if (i.inside_word()) {
        i.backward_word_start();

        // while (i.starts_word() && i.backward_char());
      }

      while (i.get_offset() >= j.get_offset()) {
        if (i.backward_word_start()) {
          this.words--;
          changed_words = true;
        } else {
          break;
        }
      }
    }

    base.delete_range(start, end);

    if (changed_words)
      this.notify_property("words");
  }

  public override void insert_text(Gtk.TextIter location, string text, int length) {
    int insertion = location.get_offset();

    base.insert_text(ref location, text, length);

    if (length == 1) {
      Gtk.TextIter i;
      this.get_iter_at_offset(out i, insertion);

      if (i.starts_word()) {
        words++;
        this.notify_property("words");
      }
    } else {
      // Idly Counting of Words
      // chunks into 2KB of ASCII characters in order to allow interaction
      // with the interface
      Idle.add(() => {

        int leftover_length = 0;

        if (length > 2048) {
          leftover_length = length - 2048;
          length = 2048;
        }

        Gtk.TextIter i;
        this.get_iter_at_offset(out i, insertion);

        Gtk.TextIter end;
        this.get_iter_at_offset(out end, insertion + length);

        // set i to the first word after the insert location
        // if it is not a word start
        if (!i.starts_word()) {
          while (!i.is_end() && !i.starts_word()) {
            i.forward_char();
          }
        }

        bool changed = false;

        // count word starts backwards from end of inserted text
        // untill you reach the word start of i
        while (!end.equal(i)) {
          if (end.backward_word_start()) {
            this.words++;
            changed = true;
          } else {
            break;
          }
        }

        if (changed) {
          this.notify_property("words");
        }

        if (leftover_length > 0) {
          insertion += length;
          length = leftover_length;

          return true;
        }

        return false;
      });
    }
  }
}
