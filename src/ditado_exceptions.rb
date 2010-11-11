

module Ditado

  class DitadoException < Exception
  end
  
  class DitadoAlreadyInittedException < DitadoException
  end
  
  class IssueIdNotExistentException < DitadoException
  end
  
  class IssueIDAlreadyExistentException < DitadoException
  end
  
end