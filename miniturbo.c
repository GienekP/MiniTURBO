/*--------------------------------------------------------------------*/
/* MiniTURBO                                                          */
/* by GienekP                                                         */
/* (c) 2023                                                           */
/*--------------------------------------------------------------------*/
#include <stdio.h>
/*--------------------------------------------------------------------*/
typedef unsigned char U8;
/*--------------------------------------------------------------------*/
#include "miniturbo.h"
/*--------------------------------------------------------------------*/
U8 saveCAR(const char *filename, U8 type, const U8 *data, unsigned int size)
{
	U8 header[16]={0x43, 0x41, 0x52, 0x54, 0x00, 0x00, 0x00, 0xFF,
		           0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00};
	U8 ret=0;
	int i,sum=0;
	FILE *pf;
	for (i=0; i<size; i++) {sum+=data[i];};
	header[7]=type;
	header[8]=((sum>>24)&0xFF);
	header[9]=((sum>>16)&0xFF);
	header[10]=((sum>>8)&0xFF);
	header[11]=(sum&0xFF);
	pf=fopen(filename,"wb");
	if (pf)
	{
		i=fwrite(header,sizeof(U8),16,pf);
		if (i==16)
		{
			i=fwrite(data,sizeof(U8),size,pf);
			if (i==size) 
			{
				printf("Save \"%s\"  Type: 0x%02X ( %i )\n",filename,type,type);
				ret=1;
			};			
		};
		fclose(pf);
	};
	return ret;
}
/*--------------------------------------------------------------------*/
void fillFF(U8 *data, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) {data[i]=0xFF;};
}
/*--------------------------------------------------------------------*/
unsigned int BuildStandard(U8 *data, U8 *bank, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) {data[i+8192-size]=bank[i];};
	return 8192;
}
/*--------------------------------------------------------------------*/
unsigned int BuildSXEGS128(U8 *data, U8 *bank, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) {data[i+(128*1024)-size]=bank[i];};
	return (128*1024);
}
/*--------------------------------------------------------------------*/
unsigned int BuildSXEGS512(U8 *data, U8 *bank, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) {data[i+(512*1024)-size]=bank[i];};
	return (512*1024);
}
/*--------------------------------------------------------------------*/
unsigned int BuildMaxFlash1Mb(U8 *data, U8 *bank, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) 
	{
		U8 x=bank[i];
		if ((i==(size-18)) && (x=0x80)) {x=0x10;};
		data[i+8192-size]=x;
		data[i+(128*1024)-size]=x;
	};
	return (128*1024);
}
/*--------------------------------------------------------------------*/
unsigned int BuildMaxFlash8Mb(U8 *data, U8 *bank, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) 
	{
		U8 x=bank[i];
		data[i+8192-size]=x;
		data[i+(1024*1024)-size]=x;
	};
	return (1024*1024);
}
/*--------------------------------------------------------------------*/
int main( int argc, char* argv[] )
{
	U8 data[1024*1024];
	unsigned int size;
	printf("MiniTurbo cart builder\n(c) GienekP\n");
	
	fillFF(data,sizeof(data));
	size=BuildStandard(data,miniturbo_bin,miniturbo_bin_len);
	saveCAR("Standard.car",1,data,size);

	fillFF(data,sizeof(data));
	size=BuildSXEGS128(data,miniturbo_bin,miniturbo_bin_len);
	saveCAR("SXEGS128.car",35,data,size);

	fillFF(data,sizeof(data));
	size=BuildSXEGS512(data,miniturbo_bin,miniturbo_bin_len);
	saveCAR("SXEGS512.car",37,data,size);

	fillFF(data,sizeof(data));
	size=BuildMaxFlash1Mb(data,miniturbo_bin,miniturbo_bin_len);
	saveCAR("MaxFlash1Mb.car",41,data,size);

	fillFF(data,sizeof(data));
	size=BuildMaxFlash8Mb(data,miniturbo_bin,miniturbo_bin_len);
	saveCAR("MaxFlash8Mb.car",42,data,size);
	
	return 0;
}
/*--------------------------------------------------------------------*/
