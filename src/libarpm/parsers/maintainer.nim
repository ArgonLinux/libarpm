import std/[strutils], ../io

type
  Contacts* = ref object
    github*, mastodon*, email*, gitlab*: string

  Maintainer* = ref object
    realName*: string                        ## The maintainer's real name
    contacts*: Contacts                      ## The maintainer's contacts

proc maintainer*(mStr: string): Maintainer =
  var 
    curr: char
    pos: int

    realName: string
    contacts = Contacts()

    cContactMeth: string
    cContactMethDone: bool

  while curr != '(':
    curr = mStr[pos]
    
    # well, this is stupid.
    if curr == '(':
      inc pos
      realName = realName[0..realName.len-2]
      break
    
    realName &= curr

    if pos >= mStr.len:
      error("While parsing maintainer string: expected atleast 1 contact source, got EOF.", true)

    inc pos

  while curr != ')':
    curr = mStr[pos]
    
    # this too, is fairly asanine.
    if curr == ')':
      inc pos
      break

    if curr == ':':
      if cContactMeth.len < 1:
        error("While parsing contact: got no method name, got '@' instead.", true)
      
      cContactMeth = toLowerAscii(cContactMeth)
      cContactMethDone = true
      inc pos
      continue

    if curr == ',':
      reset cContactMethDone
      reset cContactMeth
      inc pos
      continue
    
    if not cContactMethDone:
      cContactMeth &= curr
    else:
      case cContactMeth
      of "gh", "github":
        contacts.github &= curr
      of "gl", "gitlab":
        contacts.gitlab &= curr
      of "email", "mail":
        contacts.email &= curr
      of "mstdn", "mastodon", "fedi":
        contacts.mastodon &= curr
      else:
        error("While parsing contact: invalid contact method: " & cContactMeth)

    inc pos
  
  Maintainer(
    realName: realName,
    contacts: contacts
  )
