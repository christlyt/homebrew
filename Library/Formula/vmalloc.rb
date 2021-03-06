require 'formula'

class VmallocDownloadStrategy < CurlDownloadStrategy
  # downloading from AT&T requires using the following credentials
  def credentials
    'I accept www.opensource.org/licenses/cpl:.'
  end

  def curl(*args)
    args << '--user' << credentials
    super
  end
end

class Vmalloc < Formula
  homepage 'http://www2.research.att.com/sw/download/'
  url 'http://www2.research.att.com/~gsf/download/tgz/vmalloc.2005-02-01.tgz',
      :using => VmallocDownloadStrategy
  sha1 '13e45960831226b2b2ac93cdbe23d1d4c6e7eb38'
  version '2005-02-01'

  def install
    # Vmalloc makefile does not work in parallel mode
    ENV.deparallelize
    # override Vmalloc makefile flags
    inreplace Dir['src/**/Makefile'] do |s|
      s.change_make_var! "CC", ENV.cc
      s.change_make_var! "CXFLAGS", ENV.cflags
      s.change_make_var! "CCMODE", ""
    end
    # make all Vmalloc stuff
    system "/bin/sh ./Runmake"
    # install manually
    # put all includes into a directory of their own
    (include + "vmalloc").install Dir['include/*.h']
    lib.install Dir['lib/*.a']
    man.install 'man/man3'
  end

  def caveats; <<-EOS.undent
    We agreed to the OSI Common Public License Version 1.0 for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end
