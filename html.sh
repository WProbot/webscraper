#!/bin/bash

#
# html.sh  v0.1
#
# start url = site.txt first line
#

  mkdir -p flag data html


  test -f html/_index.html || echo $(head -1 site.txt) html/_index.html > flag/_index.flag


  FLAG=flag/$(ls -1 flag/ | grep flag$ | head -1)
  test -f $FLAG || exit
  URL=$(cut -f 1 -d " " $FLAG)
  HTML=$(cut -f 2 -d " " $FLAG)


  echo $URL

  curl --silent --compressed $URL > $HTML

  grep -q "</html>" $HTML
  test $? -eq 0 || exit
  echo $URL $HTML >> data/all-url.txt
  rm $FLAG


  lynx --dump $HTML | gawk -v URL=$URL '

    BEGIN {
      getline < "site.txt";
      gsub("^https*:/+", "");
      gsub("/.*$", "");
      domain = $0;
    }

    flag && $1 ~ /[0-9]+[.]/ && $2 ~ /file:/ {
      gsub("file:///",          URL, $2);
      gsub("file://localhost/", URL, $2);
    }

    flag && $1 ~ /[0-9]+[.]/ && $2 ~ /https*:/ {
      url = $2;
      if(!_[url]++ && index(url, domain)) {
        file = url2file(url);
        html = "html/" file ".html";
        flag = "flag/" file ".flag";
         if(0 < (getline < html)) {
           close(html);
         } else {
           if(file) {
             print url, html > flag;
           }
         }
      }
    }

    /^References/ {
      flag++;
    }

    function url2file(s) {
      gsub("^.*https*:/+", "", s);
      gsub("^" domain "/+", "", s);
      gsub("/+$", "", s);
      gsub("[?#].*$", "", s);
      gsub("[./]", "_", s);
      return s;
    }

  '


