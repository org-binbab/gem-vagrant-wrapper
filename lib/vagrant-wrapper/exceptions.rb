class VagrantWrapper
  class Exceptions
    class Version < RuntimeError ; end
    class NotInstalled < Version ; end
  end
end
