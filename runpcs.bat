copy g:\pcs-1.0-SNAPSHOT.jar c:\pcs
java -jar -Djdbc.connection="jdbc:oracle:thin:@192.168.1.110:1521:pcs" -Dlog.dir="c:\\pcs\\logs\\" -Dhost.pwd="Sa1vation" -Dhost.ip="192.168.1.110" -Dhost.port="47294" -Dprinter="CUPS_PDF" pcs-1.0-SNAPSHOT.jar 
