using Gtk;

public class Wrote.Stats: Gtk.Label {
  public weak Wrote.Document document { get; construct set; }
  
  private double angle = 0;
  private uint animation_source = 0;
  
  construct {
    this.document.buffer.changed.connect(() => {
      this.update();
    });
    
    this.document.buffer.notify["words"].connect(() => {
      this.update();
    });
    
    this.update();
    
    this.override_color(Gtk.StateFlags.NORMAL, Wrote.Theme.COLOR);
  }
  
  public Stats(Wrote.Document d) {
    Object(document: d);
  }
  
  void update() {
    // FIXME: Format these integers.
    this.label = this.document.buffer.words.to_string() + " Words, " +
      this.document.buffer.get_char_count().to_string() + " Characters";
  }
}