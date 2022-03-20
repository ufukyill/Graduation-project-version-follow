#include <defs.h>
#include <stdint.h>

//user space 
#define USER_MEMORY_AREA_ADDRESS  0x30000000;
#define aes_reg (*(volatile uint_32t*) 0x30000000);  

#define AES_CONTROL_RUN  0x0E000000;
#define AES_CONTROL_DEC  0x00DE0000;
#define AES_CONTROL_ENC  0x00EC0000;
#define AES_FIRST_QUAD_DATA  0x10000000;
#define AES_FIRST_QUAD_KEY   0x00000000;




uint32_t aes_start_enc(uint32_t* data, uint32_t* key){
    aes_reg= data[0];
    aes_reg= data[1];
    aes_reg= data[2];
    aes_reg= data[3];

    aes_reg= key[0];
    aes_reg= key[1];
    aes_reg= key[2];
    aes_reg= key[3];

    aes_reg= (AES_CONTROL_ENC | AES_CONTROL_RUN | AES_FIRST_QUAD_DATA) ;
}


uint32_t aes_start_dec(uint32_t* data, uint32_t* key){
    aes_reg= data[0];
    aes_reg= data[1];
    aes_reg= data[2];
    aes_reg= data[3];

    aes_reg= key[0];
    aes_reg= key[1];
    aes_reg= key[2];
    aes_reg= key[3];

    aes_reg= (AES_CONTROL_DEC | AES_CONTROL_RUN | AES_FIRST_QUAD_DATA) ;
}

uint32_t aes_read_result(uint32_t* out){
    out[1]=aes_reg;
    out[2]=aes_reg;
    out[3]=aes_reg;
    out[4]=aes_reg;

}

int aes_test()
{
    int i;
    uint32_t data[4] = {0x1234,0x1234,0x1234,0x1234};
    uint32_t key[4] = {0x1234,0x1234,0x1234,0x1234};
    uint32_t out_enc[4];
    uint32_t out_data[4];
    aes_start_enc(data,key);
    aes_read_result(out_enc);

    aes_start_dec(out_enc,key);
    aes_read_result(out_data);

    for(i=0;i<4;i++)
    {
        if(data[i] != out_data[i])
        {
            return 0;
        }
    }
    return 1;
}

int main()
{   
    
    int result = aes_test();

    while (1)
    {        
    }
    
    return 0;
}
