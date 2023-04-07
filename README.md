Source for my website :  [https://ichennn.github.io/](https://ichennn.github.io/)


### Modified hyde-x theme.

1. author name >> site title
2. Css override. Theme color and sidebar layout has been changed.
3. Favicon changed.
(2023/4 updated)
4. Fix render error in `layouts/partials/sidebar.html`
```
-    <p><font size=2>Copyright &copy; {{ .Now.Format "2006" }} <a href="{{ "/LICENSE" | absURL }}">License</a><br/>

+    <p><font size=2>{{ with .Site.Params.copyright }}{{.}}{{ else }}&copy; {{ now.Format "2006"}}. All rights reserved. {{end}}<br/>
```
5. Fix render error in `layouts/partials/head.html`
```
-    {{ with .RSSLink }}<link href="{{ . }}" rel="alternate" type="application/rss+xml" title="{{ $siteTitle }} &middot; {{ $authorName }}" />{{ end }}

+    { range .AlternativeOutputFormats -}}
       {{ printf `<link href="%s" rel="%s" type="%s" title="%s" />` .Permalink .Rel .MediaType.Type $.Site.Title | safeHTML }}
     { end -}}
```
6. Update deprecated pagination feature in `layouts/index.html`
```
-    {{ $paginator := .Paginate (where .Data.Pages "Type" "post") }}

+    {{ $paginator := .Paginate (where .Site.RegularPages "Type" "post") }}
```


### Memo: How to remove submodule (in case changing theme)

* https://stackoverflow.com/questions/1260748/how-do-i-remove-a-submodule/36593218#36593218
```
# Remove the submodule entry from .git/config
git submodule deinit -f path/to/submodule

# Remove the submodule directory from the superproject's .git/modules directory
rm -rf .git/modules/path/to/submodule

# Remove the entry in .gitmodules and remove the submodule directory located at path/to/submodule
git rm -f path/to/submodule
```
