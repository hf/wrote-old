using Gtk;

public enum Wrote.Animation {
  NONE,
  FADING_IN,
  FADING_OUT
}

public class Wrote.Stats: Gtk.Label {
  public weak Wrote.Document document { get; construct set; }
  
  private Wrote.Animation animation = Wrote.Animation.NONE;
  
  private double animation_angle = Math.PI_2;
  private uint animation_source = 0;
  
  construct {
    this.app_paintable = true;
    
    this.document.buffer.changed.connect(() => {
      this.update();
    });
    
    this.document.buffer.notify["words"].connect(() => {
      this.update();
    });
    
    this.update();
    
    this.override_color(Gtk.StateFlags.NORMAL, Wrote.Theme.COLOR);
    
    this.show.connect(() => {
      this.animation_angle = Math.PI_2;
      this.fade_in();
    });
  }
  
  public Stats(Wrote.Document d) {
    Object(document: d);
  }
  
  void update() {
    this.label = @"$(this.document.buffer.words) Words / $(this.document.buffer.get_char_count()) Characters";
  }
  
  public override bool draw(Cairo.Context ctx) {    
    double opacity = Math.sin(this.animation_angle);
    
    base.draw(ctx);
      
    ctx.save();
      
      Gtk.Allocation alloc; this.get_allocation(out alloc);
      
      ctx.rectangle(alloc.x, alloc.y, alloc.width, alloc.height);
      ctx.clip();
      
      ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);
      
      ctx.paint_with_alpha(opacity);
      
    ctx.restore();
    
    return true;    
  }
  
  public void fade_out() {
    
    if (this.animation == Wrote.Animation.FADING_OUT)
      return;
    
    this.animation = Wrote.Animation.FADING_OUT;
    
    if (this.animation_source == 0) {
      this.animation_source = Timeout.add(Wrote.Theme.REFRESH_RATE, this.animate);
    }
  }
  
  public void fade_in() {
    
    if (this.animation == Wrote.Animation.FADING_IN)
      return;
  
    this.animation = Wrote.Animation.FADING_IN;
    
    if (this.animation_source == 0) {
      this.animation_source = Timeout.add(Wrote.Theme.REFRESH_RATE, this.animate);
    }
  }
  
  bool animate() {
    
    if (this.animation == Wrote.Animation.NONE) {
      
      this.animation_source = 0;
      return false;
    }
    
    if (this.animation == Wrote.Animation.FADING_IN) {
      this.animation_angle -= Wrote.Theme.FADING_RATE;
    } else {
      this.animation_angle += Wrote.Theme.FADING_RATE;
    }
    
    if (this.animation_angle >= Math.PI_2 &&
        this.animation == Wrote.Animation.FADING_OUT)
    {
      this.animation_angle = Math.PI_2;
      this.animation = Wrote.Animation.NONE;
      
    } else if (this.animation_angle <= 0 &&
      this.animation == Wrote.Animation.FADING_IN)
    {
      this.animation_angle = 0.0;
      this.animation = Wrote.Animation.NONE;
    }
    
    this.queue_draw();
    
    return true;
  }
}