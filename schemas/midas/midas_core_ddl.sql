CREATE TABLE address
    (address_id                     NUMBER(6,0) NOT NULL,
    address_text_1                 VARCHAR2(70 BYTE) NOT NULL,
    address_text_2                 VARCHAR2(70 BYTE),
    address_text_3                 VARCHAR2(50 BYTE),
    address_text_4                 VARCHAR2(50 BYTE),
    address_town                   VARCHAR2(30 BYTE),
    address_county                 VARCHAR2(30 BYTE) NOT NULL,
    address_country                VARCHAR2(60 BYTE) NOT NULL,
    post_code                      VARCHAR2(9 BYTE)
  ,
  CONSTRAINT PKADDRESS
  PRIMARY KEY (address_id)
  USING INDEX
  );
