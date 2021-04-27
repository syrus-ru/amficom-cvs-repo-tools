## Подходы к преобразованию CVS-репозитория в Git

1. [`cvs-fast-export`](http://www.catb.org/esr/cvs-fast-export/)
    - Пример командной строки:
        ```bash
        git init --bare
        # Импорт из локального CVS-репозитория
        find path-to-cvs-repo -name '*,v' | cvs-fast-export -A authormap -k kv -P | git fast-import
        # Импорт из удалённого CVS-репозитория
        cvssync | cvs-fast-export -A authormap -k kv -P | git fast-import
        ```
    - Если не указать ключ `-P`, содержимое каталога `CVSROOT/` будет
      проигнорировано.
    - Создаёт файл `.gitignore` в корне репозитория и добавляет его в первый же
      коммит.
    - Самостоятельно преобразует все существующие файлы `.cvsignore` в
      `.gitignore`.
1. `git cvsimport`
    - Пример командной строки:
        ```bash
        git cvsimport -i -d ${CVSROOT} -A authormap -k module-name -C project.git
        ```
    - Недостатки
        - Не может преобразовать CVS-репозиторий целиком (только по одному
          модулю за проход).
1. [`cvs2git`](http://web.archive.org/web/20200222121735/http://cvs2svn.tigris.org/cvs2git.html)
    - Пример командной строки:
        ```bash
        cvs2git --blobfile=project.blob --dumpfile=project.dump --encoding=UTF-8 --keep-cvsignore path-to-cvs-repo
        git init --bare
        cat project.blob project.dump | git fast-import
        ```
    - `cvs2git` добавляет синтетические коммиты от имени автора `(no author)`, и
      этот пользователь должен присутствовать в файле `authormap`.
    - Недостатки
        - Поддерживает _author mapping_, но лишь через специальную структуру
          `author_transforms`, см. пример конфигурационного файла в
          `/usr/share/doc/cvs2svn/examples/cvs2git-example.options.gz`.
          Идентичного результата, но более удобным способом можно достичь,
          используя связку из `cvs2svn` + `svn2git`.
        - CVS-тэги преобразуются в виде отдельных коммитов (а не тэгов в смысле
          Git). Автор этих коммитов &mdash; синтетический `(no author)`.
1. [`cvs2svn`](http://web.archive.org/web/20200222121542/http://cvs2svn.tigris.org:80/) + [`svn2git`](https://github.com/nirvdrum/svn2git)
    - Пример командной строки:
        ```bash
        cvs2svn --encoding=UTF-8 --keep-cvsignore -s project.svn path-to-cvs-repo
        svn2git --authors authormap file:///full/path/to/project.svn
        ```
    - `svn2git` является тонкой обёрткой над `git svn`.
    - `cvs2svn` добавляет синтетические коммиты от имени автора `(no author)`, и
      этот пользователь должен присутствовать в файле `authormap`.
    - Недостатки
        - CVS-тэги преобразуются в виде отдельных коммитов (а не тэгов в смысле
          Git). Автор этих коммитов &mdash; синтетический `(no author)`.
1. [`cvs2svn`](http://web.archive.org/web/20200222121542/http://cvs2svn.tigris.org:80/) + `git svn clone`
   - Пример командной строки:
       ```bash
       cvs2svn --encoding=UTF-8 --keep-cvsignore -s project.svn path-to-cvs-repo
       git svn clone -A authormap -s --no-metadata file:///full/path/to/project.svn project.git
       ```
   - `cvs2svn` добавляет синтетические коммиты от имени автора `(no author)`, и
     этот пользователь должен присутствовать в файле `authormap`.
   - CVS-репозиторий должен находиться локально (может быть получен с
     использованием `cvssync`).
   - Ключи `-T`/`-b`/`-t` (либо `-s`) при вызове `git svn clone` должны быть
     указаны, иначе `trunk/`, `branches/` и `tags/` утратят первоначальный
     смысл и будут импортированы как обычные подкаталоги.
   - Недостатки
      - Хотя `cvs2svn`, определённо, сохраняет CVS-тэги, они "теряются" при
        работе `git svn clone`. Лучше использовать `svn2git`.
