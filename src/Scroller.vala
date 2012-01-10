using Gtk;
using Gdk;

public enum Wrote.ScrollingDirection {
  VERTICAL,
  HORIZONTAL,
  BOTH
}

public class Wrote.Scroller: Gtk.Bin {
  public ScrollingDirection scrolling_direction { get; private construct set; default = ScrollingDirection.BOTH; }
  
  public Gtk.Adjustment vadjustment { get; construct set; }
  public Gtk.Adjustment hadjustment { get; construct set; }
  
  construct {
    this.add_events(Gdk.EventMask.SCROLL_MASK);
    
    // FIXME: Maybe should do full adjustment checks...
    // ensure no artifacts arise while scrolling
    // it is a pixbuf after all
    this.vadjustment.notify["value"].connect(() => {
      Gtk.Allocation allocation;
      
      this.get_allocation(out allocation);
      this.queue_draw_area(allocation.x, allocation.y, allocation.width, allocation.height);    });
    
    this.hadjustment.notify["value"].connect(() => {
      Gtk.Allocation allocation;
      this.get_allocation(out allocation);
      
      this.queue_draw_area(allocation.x, allocation.y, allocation.width, allocation.height);
    });
  }
  
  public Scroller(Gtk.Adjustment v, Gtk.Adjustment h) {    
    Object(vadjustment: v, hadjustment: h);
  }
  
  public override void get_preferred_width(out int minimum, out int natural) {
    minimum = 0;
    natural = 0;
    
    this.get_child().get_preferred_width(out minimum, out natural);
    
    natural = 0;
    
    if (this.scrolling_direction == ScrollingDirection.HORIZONTAL || this.scrolling_direction == ScrollingDirection.BOTH) {
      minimum = Wrote.Theme.EDITOR_WIDTH;
      natural = minimum;
    }
  }
  
  public override void get_preferred_height(out int minimum, out int natural) {
    minimum = 0;
    natural = 0;
    
    this.get_child().get_preferred_height(out minimum, out natural);
    
    if (this.scrolling_direction == ScrollingDirection.VERTICAL || this.scrolling_direction == ScrollingDirection.BOTH) {
      minimum = Wrote.Theme.EDITOR_HEIGHT;
      natural = minimum;
    }
  }
  
  public override void size_allocate(Gtk.Allocation allocation) {
    this.set_allocation(allocation);
    
    Gtk.Allocation child_allocation = Gtk.Allocation();
    child_allocation.x = allocation.x;
    child_allocation.y = allocation.y;
    child_allocation.width = allocation.width;
    child_allocation.height = allocation.height;
    
    this.get_child().size_allocate(child_allocation);
  }
  
  public override bool scroll_event(Gdk.EventScroll event) {
    
    double increment = this.vadjustment.step_increment;
    
    if ((event.state & Gdk.ModifierType.SHIFT_MASK) != 0) {
      event.direction += 2; 
      increment = this.hadjustment.step_increment;
    }
    
    switch (event.direction) {
      case Gdk.ScrollDirection.UP:
        this.vadjustment.value -= increment;
        break;
      
      case Gdk.ScrollDirection.DOWN:
        this.vadjustment.value += increment;
        break;
        
      case Gdk.ScrollDirection.LEFT:
        this.hadjustment.value -= increment;
        break;
      
      case Gdk.ScrollDirection.RIGHT:
        this.hadjustment.value += increment;
        break;
    }
    
    return false;
  }
}