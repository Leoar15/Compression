%Second encoder, compare the gery level of the pixel 
%with the previous pixel in same row.
%% Initialization of varibles
first=0;        %flag for first value
flag_write=0;   %flag for write-in
%flags for different types of row
flag00=0;       %all zero
flag11=0;       %different row
flag01=0;       %identical row
flags=0;        %flag for continuity
x=4;
encodedmatrix=zeros(1,8);
pixelbuffer=0;
%% Main program
%matrix =         %Put your own data matrix here
[numRows, numCol] = size(matrix);
if l==1
    buffer=zeros(1,numCol);
end
for r=1:numRows
    if all(matrix(r,:)==0)
        if flag00==0
            dic(1)=0;       %first prefix
            dic(2)=0;       %second prefix
            dic(3)=r;       %record row index
            flag_write=1;
            flags=1;
        end
        flag00=1;
        flag11=0;
        flag01=0;
    elseif isequal(matrix(r,:),buffer) %identical with previous row
        if flag01==0
            dic(1)=0;
            dic(2)=1;
            dic(3)=r;
            flag_write=1;
            flags=1;
        end
        flag00=0;
        flag11=0;
        flag01=1;
    else %different rows
        if flag11==1
            x=1;
        end
        for i=1:numCol
            if matrix(r,i)~=pixelbuffer
                dic(x)=i;
                x=x+1;
                if matrix(r,i)==1
                    dic(x)=1;
                    x=x+1;
                elseif matrix(r,i)==2
                    dic(x)=2;
                    x=x+1;
                elseif matrix(r,i)==3
                    dic(x)=3;
                    x=x+1;
                elseif matrix(r,i)==0
                    dic(x)=0;
                    x=x+1;
                end
                pixelbuffer=matrix(r,i);
            end
            if i==numCol
                dic(x)=0;
            end
        end
        if flag11==0
            dic(1)=1;
            dic(2)=1;
            dic(3)=r;
            flags=0;
        else
            flags=1;
        end
        flag11=1;
        flag00=0;
        flag01=0;
        flag_write=1;
    end
    if flag_write==1
        if flags==0
            order=3;
            recsize=length(dic);
            encoderbuffer=zeros((recsize-4)/2+2,9);
            encoderbuffer(1,1:2)=dic(1);
            binbuffer=fliplr(de2bi(dic(3)-1));
            if length(binbuffer)<16
                zerobuffer=zeros(1,16-length(binbuffer));
                binbuffer=[zerobuffer,binbuffer];
            end
            encoderbuffer(1,3:9)=binbuffer(1:7);
            encoderbuffer(2,:)=binbuffer(8:16);
            for i=4:2:(recsize-2)
                binbuffer1=fliplr(de2bi(dic(i)));
                binbuffer2=fliplr(de2bi(dic(i+1)));
                if length(binbuffer1)<6
                    zerobuffer=zeros(1,6-length(binbuffer1));
                    binbuffer1=[zerobuffer,binbuffer1];
                end
                if length(binbuffer2)<2
                    binbuffer2=[0,binbuffer2];
                end
                binbuffer=[binbuffer1,binbuffer2];
                encoderbuffer(order,1)=1;
                if i==recsize-2
                    encoderbuffer(order,1)=0;
                end
                encoderbuffer(order,2:9)=binbuffer;
                order=order+1;
            end
        elseif flags==1&&flag11==1
            order=1;
            recsize=length(dic);
            encoderbuffer=zeros((recsize-1)/2,9);
            for i=1:2:(recsize-2)
                binbuffer1=fliplr(de2bi(dic(i)));
                binbuffer2=fliplr(de2bi(dic(i+1)));
                if length(binbuffer1)<6
                    zerobuffer=zeros(1,6-length(binbuffer1));
                    binbuffer1=[zerobuffer,binbuffer1];
                end
                if length(binbuffer2)<2
                    binbuffer2=[0,binbuffer2];
                end
                encoderbuffer(order,1)=1;
                if i==recsize-2&&recsize~=3
                    encoderbuffer(order,1)=0;
                end
                binbuffer=[binbuffer1,binbuffer2];
                encoderbuffer(order,2:9)=binbuffer;
                order=order+1;
                if recsize<=3
                    encoderbuffer=[encoderbuffer;zeros(1,9)];
                    order=order+1;
                end
            end
        elseif flags==1&&flag00==1
            encoderbuffer=zeros(2,9);
            encoderbuffer(1,1:2)=dic(1);
            binbuffer=fliplr(de2bi(dic(3)-1));
            if length(binbuffer)<16
                zerobuffer=zeros(1,16-length(binbuffer));
                binbuffer=[zerobuffer,binbuffer];
            end
            encoderbuffer(1,3:9)=binbuffer(1:7);
            encoderbuffer(2,:)=binbuffer(8:16);
        elseif flags==1&&flag01==1
            encoderbuffer=zeros(1,9);
            encoderbuffer(2)=1;
        end
        if first==0
            encodedmatrix=encoderbuffer;
            first=1;
        else
            encodedmatrix=[encodedmatrix;encoderbuffer];
        end
        clear dic;
        x=4;
        flag_write=0;
        buffer=matrix(r,:);
        pixelbuffer=0;
    end
end
encoderbuffer=ones(2,9);
encoderbuffer(1,1)=0;
encoderbuffer(1,2)=0;
encodedmatrix=[encodedmatrix;encoderbuffer];