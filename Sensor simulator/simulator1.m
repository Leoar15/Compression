function  simulator1(minbloblong, minblobwide,maxbloblong,maxblobwide,minrowspacing,maxrowspacing,maxblobincol,maxrowseg,datarow,datacol)
%SIMULATOR1, a function to generate artifical data
%Parameters:
%1. Minimum row for blob 2.Minimum column for blob
%3. Maximum row for blob 2.Maximum column for blob
%5. Minimum numbers of all zero row 6.Maximum numbers of all zero row
%7.Maximum number of blob allowed to be inserted in a segment
%8.Maximum number of rows in a segment
%9. Maximum row for data space 10. Maximum column for data space
load blobs.mat;
rowmatrix=zeros(1,length(blobs));
colmatrix=zeros(1,length(blobs));
for i=1:length(blobs)
    [numRows, numCol] = size(blobs{i});
    rowmatrix(i)=numRows;
    colmatrix(i)=numCol;
end
x=1;
for i=1:length(blobs)
    if rowmatrix(i)<=maxbloblong&&colmatrix(i)<=maxblobwide&&rowmatrix(i)>=minbloblong&&colmatrix(i)>=minblobwide
        cell1{x}=blobs{i};
        x=x+1;
    end
end
cellnew=cell1;
minrow=floor(mean(rowmatrix)); %set threshold to get rid of overflow
mincol=floor(mean(colmatrix));
currentblobincol=maxblobincol;
data=zeros(datarow,datacol);
currentrow=1;
colbuffer=1;
rowbuffer=1;
while currentrow<datarow
    while currentblobincol>0
        randblob = randi([1, length(cellnew)]); %get random order for blob
        blobbuffer=cellnew{randblob}; %use above order to get blob
        [blobrow, blobcol] = size(blobbuffer);
        while (currentrow+blobrow-1>datarow)||(colbuffer+blobcol-1>datacol)   %if row overflow, re-select order
            randblob = randi([1, length(cellnew)]);
            blobbuffer=cellnew{randblob};
            [blobrow, blobcol] = size(blobbuffer);
        end

        randcol=randi([colbuffer,  datacol]); %randomly select a column
        while randcol+blobcol-1>datacol % if overflow, re-select
            randcol=randi([colbuffer,  datacol]);
        end
        randseg=randi([0,maxrowseg]); %randomly select a segment
        while currentrow+randseg+blobrow-1>datarow % if overflow, re-select
        randseg=randi([0,maxrowseg]);
        end
        if randseg+blobrow>rowbuffer   %record largest row
            rowbuffer=blobrow+randseg;
        end
        data(currentrow+randseg:currentrow+randseg+blobrow-1,randcol:randcol+blobcol-1)=blobbuffer; %write blob in data
        colbuffer=randcol+blobcol;   %record current column
        currentblobincol=currentblobincol-1;  %record the number of blob allowed to be written
        if datacol-colbuffer+1<mincol %if overflow, break
            currentblobincol=0;
        end
    end
    currentrow=currentrow+rowbuffer+1; %updata current index of row
    colbuffer=1;   %reset buffer
    rowbuffer=1;
    if datarow-currentrow+1<minrow  %get rid of overflowing
        currentrow=2^16;
    else
        rand0 = randi([minrowspacing, maxrowspacing]);
        while currentrow+rand0-1>=datarow
            rand0 = randi([1, maxrowspacing]);
        end
    end
currentrow=currentrow+rand0;
currentblobincol=maxblobincol;  %reset number of blob allowed in buffer
end
data=uint8(data);
writematrix(data, 'simulator.csv');
end

