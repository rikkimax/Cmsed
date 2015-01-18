module cmsed.runners.util;
import cmsed.base.config;
import dvorm.email;

void configureEmail() {
    // configure the email system provided by dvorm.
    if (configuration.email.receive.host != "") {
        ReceiveClientConfig rconfig;
        ReceiveClientType rtype;
        
        SendClientConfig sconfig;
        SendClientType stype;
        
        if (configuration.email.receive.port > 0) {
            if (configuration.email.receive.secure)
                rconfig = ReceiveClientConfig(configuration.email.receive.host, configuration.email.receive.port, configuration.email.receive.user, configuration.email.receive.password, ClientSecurity.SSL_StartTLS);
            else
                rconfig = ReceiveClientConfig(configuration.email.receive.host, configuration.email.receive.port, configuration.email.receive.user, configuration.email.receive.password, ClientSecurity.None);
        }
        
        if (configuration.email.send.port > 0) {
            if (configuration.email.send.secure)
                sconfig = SendClientConfig(configuration.email.send.host, configuration.email.send.port, configuration.email.send.user, configuration.email.send.password, ClientSecurity.SSL_StartTLS);
            else
                sconfig = SendClientConfig(configuration.email.send.host, configuration.email.send.port, configuration.email.send.user, configuration.email.send.password, ClientSecurity.None);
        }
        
        switch(configuration.email.receive.type) {
            case EmailReceiveServerType.Pop3:
                rtype = ReceiveClientType.Pop3;
                
                if (configuration.email.receive.port <= 0) {
                    if (configuration.email.receive.secure)
                        rconfig = ReceiveClientConfig.securePop3(configuration.email.receive.host, configuration.email.receive.user, configuration.email.receive.password);
                    else
                        rconfig = ReceiveClientConfig.insecurePop3(configuration.email.receive.host, configuration.email.receive.user, configuration.email.receive.password);
                }
                
                break;
            default:
                return;
        }
        
        switch(configuration.email.send.type) {
            case EmailSendServerType.SMTP:
                stype = SendClientType.SMTP;
                
                if (configuration.email.send.port <= 0) {
                    if (configuration.email.send.secure)
                        sconfig = SendClientConfig.secureSmtp(configuration.email.send.host, configuration.email.send.user, configuration.email.send.password, configuration.email.send.defaultFrom);
                    else
                        sconfig = SendClientConfig.insecureSmtp(configuration.email.send.host, configuration.email.send.user, configuration.email.send.password, configuration.email.send.defaultFrom);
                }
                
                break;
            default:
                return;
        }
        
        setEmailReceiveConfig(rtype, rconfig);
        setEmailSendConfig(stype, sconfig);
    }
}