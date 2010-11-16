

module Ditado

  class DitadoException < Exception
  end
  
  class DitadoAlreadyInittedException < DitadoException
  end
  
  class IssueIdNotExistentException < DitadoException
  end
  
  class IssueIDAlreadyExistentException < DitadoException
  end
  
  class DitadoNotInitializedException < DitadoException
  end
  
  class DitadoWikiPageAlreadyExistsException < DitadoException
  end
  
  class InvalidDitadoWikiPageNameException < DitadoException
  end
  
  class DitadoWikiPageDoesNotExistException < DitadoException
  end
  
  class InvalidModulePrefixException < DitadoException
  end
  
end