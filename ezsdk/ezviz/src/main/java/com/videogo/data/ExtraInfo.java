package com.videogo.data;
import java.util.HashMap;

import android.os.Parcel;
import android.os.Parcelable;
import android.support.v7.widget.LinearLayoutCompat;

public class ExtraInfo implements Parcelable {

    public HashMap<String,String> map = new HashMap<String,String> ();

    private String value="";
    public String name ;
    @Override
    public int describeContents() {
        return 0;
    }

    public void setValue(String _value){
        value = _value;
    }
    public String getValue(){
        return value;
    }
    @Override
    public void writeToParcel(Parcel dest, int flags) {

        dest.writeMap(map);
        dest.writeString(name);
    }
    public static final Parcelable.Creator<ExtraInfo> CREATOR = new Parcelable.Creator<ExtraInfo>() {
//重写Creator

        @Override
        public ExtraInfo createFromParcel(Parcel source) {
            ExtraInfo p = new ExtraInfo();
            p.map=source.readHashMap(HashMap.class.getClassLoader());
            p.name=source.readString();
            return p;
        }

        @Override
        public ExtraInfo[] newArray(int size) {
            // TODO Auto-generated method stub
            return null;
        }
    };


}