# RideWithMe / Prevozi

This project contains tools needed to extract data from Slovenian Facebook groups that provide city-to-city carpooling collaboration.

Experimental project by [Oto Brglez](https://otobrglez.opalab.com).

## Rake tasks

### Authenticate via Facebook
 
    rake app:authenticate  

### Update local group info

    rake groups:update_all_info

### Fetching

    rake fetch:one[699369753410792]
    rake fetch:all
   
