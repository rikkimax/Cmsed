module test.ttemplateroute;
import cmsed.base.udas;
import cmsed.base.templates;

@RouteFunction(RouteType.Get, "/template")
auto atexttemplate() {
    string templatename = Render.prerenderText("""
<html><body>
<?lua echo(args[1]) ?><br/>
From Rikki :)
</body></html>
""");

    return Render(templatename, "hi there!");
}

@RouteFunction(RouteType.Get, "/templatefile")
auto afiletemplate() {
    return Render("templates/afiletemplate.tpl", "some text muhaha!");
}

@RouteFunction(RouteType.Post, "/templatefilename")
auto givenfiletemplate(string filename) {
    return Render(filename, "some text muhaha!");
}

@RouteFunction(RouteType.Get, "/templatefilename")
auto givenfiletemplateForm() {
    return Render("templates/givenfiletemplate.tpl", "some text muhaha!");
}

@RouteFunction(RouteType.Get, "/includetemplate")
auto aincludetexttemplate() {
    string templatename = Render.prerenderText("""
<html><body>
IN&nbsp;
<?lua
    echo(I_P_INCLUDE_P_I:size(), \"<br/>\")
    include_text(\"<?lua echo(\\\"body&nbsp;\\\", I_P_INCLUDE_P_I:size()) ?>\")
    echo(\"<br/>\", I_P_INCLUDE_P_I:size())
?>
&nbsp;OUT
</body></html>
""");
    return Render(templatename);
}