
namespace Wrote {
  namespace Actions {
    public static const Gtk.ActionEntry[] MENU = {
      { "FileMenu", null, "File", null, null, null },
      { "EditMenu", null, "Edit", null, null, null }
    };
  }
  
  public static const string UI = 
  """
  <ui>
    <menubar>
      <menu action="FileMenu">
        <menuitem action="New" />
        <menuitem action="Open" />
        <separator />
        <menuitem action="Save" />
        <menuitem action="SaveAs" />
      </menu>
    </menubar>
  </ui>
  """;
}
