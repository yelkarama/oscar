package org.oscarehr.olis.model;

import java.util.ArrayList;
import java.util.List;

public class OlisMeasurementsResultDisplay {
    
    private OlisLabResultDisplay parentLab;

    private int measurementObxIndex;
    private String testResultName = "";
    private String status = "";
    private String resultValue = "";
    private String flag = "";
    private String referenceRange = "";
    private String units = "";
    private boolean isAbnormal = false;
    private String natureOfAbnormalText = "";
    private List<String> comments = new ArrayList<>();
    private boolean isAttachment = false;
            
    OlisMeasurementsResultDisplay() { }

    public int getMeasurementObxIndex() {
        return measurementObxIndex;
    }
    public void setMeasurementObxIndex(int measurementObxIndex) {
        this.measurementObxIndex = measurementObxIndex;
    }

    public OlisLabResultDisplay getParentLab() {
        return parentLab;
    }
    public void setParentLab(OlisLabResultDisplay parentLab) {
        this.parentLab = parentLab;
    }

    public String getTestResultName() {
        return testResultName;
    }
    public void setTestResultName(String testResultName) {
        this.testResultName = testResultName;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getResultValue() {
        return resultValue;
    }
    public void setResultValue(String resultValue) {
        this.resultValue = resultValue;
    }

    public String getFlag() {
        return flag;
    }
    public void setFlag(String flag) {
        this.flag = flag;
    }

    public String getReferenceRange() {
        return referenceRange;
    }
    public void setReferenceRange(String referenceRange) {
        this.referenceRange = referenceRange;
    }

    public String getUnits() {
        return units;
    }
    public void setUnits(String units) {
        this.units = units;
    }

    public boolean isAbnormal() {
        return isAbnormal;
    }
    public void setAbnormal(boolean abnormal) {
        isAbnormal = abnormal;
    }

    public String getNatureOfAbnormalText() {
        return natureOfAbnormalText;
    }
    public void setNatureOfAbnormalText(String natureOfAbnormalText) {
        this.natureOfAbnormalText = natureOfAbnormalText;
    }

    public List<String> getComments() {
        return comments;
    }
    public void setComments(List<String> comments) {
        this.comments = comments;
    }

    public boolean isAttachment() {
        return isAttachment;
    }
    public void setIsAttachment(boolean attachment) {
        isAttachment = attachment;
    }
}