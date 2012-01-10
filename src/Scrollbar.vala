using Gtk;

public class Wrote.Scrollbar: Gtk.Bin, Gtk.Orientable {
  public const int THICKNESS = 5;
  public const int SIZE = 20;
  
  public Gtk.Orientation orientation { get; set; }
  
  public Gtk.Adjustment adjustment { get; construct set; }
  
  construct {
    this.app_paintable = true;
  }
  
  public Scrollbar.vertical(Gtk.Adjustment a) {
    Object(adjustment: a);
    
    this.orientation = Gtk.Orientation.VERTICAL;
  }
  
  public Scrollbar.horizontal(Gtk.Adjustment a) {
    Object(adjustment: a);
    
    this.orientation = Gtk.Orientation.HORIZONTAL;
  }
  
  public override void get_preferred_width(out int minimum, out int natural) {
    if (this.orientation == Gtk.Orientation.VERTICAL) {
      minimum = THICKNESS;
      natural = THICKNESS;
    } else {
      minimum = SIZE;
      natural = SIZE;
    }
  }
  
  public override void get_preferred_height(out int minimum, out int natural) {
    if (this.orientation == Gtk.Orientation.VERTICAL) {
      minimum = SIZE;
      natural = SIZE;
    } else {
      minimum = THICKNESS;
      natural = THICKNESS;
    }
  }
  
  public override void size_allocate(Gtk.Allocation allocation) {
    this.set_allocation(allocation);
    
    // although we don't need it, keep when changing from EventBox to
    // normal Widget
    ///this.get_child().size_allocate(allocation);
  }
  
  public override bool draw(Cairo.Context ctx) {
    
    ctx.set_source_rgb(0, 0, 0);
    ctx.rectangle(0, 0, this.get_allocated_width(), this.get_allocated_height());
    ctx.fill();
    ctx.paint();
    
    return true;
  }
}