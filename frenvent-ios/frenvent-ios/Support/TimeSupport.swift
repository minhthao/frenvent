//
//  TimeSupport.swift
//  frenvent-ios
//
//  Created by minh thao nguyen on 6/19/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

import Foundation

class TimeSupport {
    /**
    * Get the standard date/time format of an date/time string
    * @param time in fb format (either "yyyy-MM-dd" or "yyyy-MM-dd'T'HH:mm:ss" or "yyyy-MM-dd'T'HH:mm:ssZ")
    * @return time in format of "yyyy-MM-dd' 'HH:mm:ss"
    */
    func getDateTimeInStandardFormat(dateTimeInFacebookFormat: String) -> String {
        let standardFormat = NSDateFormatter()
        standardFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let sourceFormat = NSDateFormatter()
        if (countElements(dateTimeInFacebookFormat) < 12) {
            sourceFormat.dateFormat = "yyyy-MM-dd"
        } else if (countElements(dateTimeInFacebookFormat) < 20) {
            sourceFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        } else {
            sourceFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        
        let sourceFormatDate = sourceFormat.dateFromString(dateTimeInFacebookFormat)
        let standardFormatDate = standardFormat.stringFromDate(sourceFormatDate)
        
        return standardFormatDate;
    }

    /**
    * Get the unix time of a standard time
    * @param time in standard format
    * @return unix time
    */
    func getUnixTime(dateTimeInStandardFormat: String) -> Int {
        let standardFormat = NSDateFormatter()
        standardFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = standardFormat.dateFromString(dateTimeInStandardFormat)
        let unixTime = date.timeIntervalSince1970
        return Int(unixTime);
    }

    /**
    * Get the DateTime in standard format from the unix time
    * @param unix time
    * @return time in standard format
    */
    func getDateTimeInStandardFormat(dateTimeInUnix: Int) -> String {
        let standardFormat = NSDateFormatter()
        standardFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = NSDate(timeIntervalSince1970:  Double(dateTimeInUnix))
        let standardFormatDate = standardFormat.stringFromDate(date)
        return standardFormatDate
    }

    /**
    * Get the DateTime of today in standard  format
    * @return time in standard format
    */
    func getDateTimeOfTodayInStandardFormat() -> String {
        let standardFormat = NSDateFormatter()
        standardFormat.dateFormat = "yyyy-MM-dd 00:00:00"
        
        let date = NSDate()
        let standardFormatDate = standardFormat.stringFromDate(date)
        return standardFormatDate
    }

    /**
    * Get the DateTime of ith Date away from today in standard format
    * @param ith index
    * @return time in standard time
    */
    func getDateTimeOfIthDateFromTodayInStandardFormat(ithValue: Int) -> String {
        let standardFormat = NSDateFormatter()
        standardFormat.dateFormat = "yyyy-MM-dd 00:00:00"
        
        let date = NSDate(timeIntervalSinceNow: Double(24*60*60*ithValue))
        let standardFormatDate = standardFormat.stringFromDate(date)
        return standardFormatDate
    }

    /**
    * check whether the DateTime in standard format also include hour
    * @param time in standard format
    * @return boolean
    */
    func isDateTimeSpecifiedTheHour(dateTimeInStandardFormat: String) -> Bool {
        let hourString = dateTimeInStandardFormat.substringFromIndex(11).substringToIndex(5)
        return hourString == "00:00"
    }

    /**
    * Get the display hour in the format of "h:mm a" of a unix DateTime
    * @param unix time
    * @return time in target format
    */
    func getDisplayHour(dateTimeInUnix: Int) -> String {
        let targetFormat = NSDateFormatter()
        targetFormat.dateFormat = "h:mm a"
        
        let date = NSDate(timeIntervalSince1970:  Double(dateTimeInUnix))
        let targetFormatHour = targetFormat.stringFromDate(date)
        return targetFormatHour
    }

    /**
    * Check whether two DateTimes written in standard format have the same date
    * @param time in standard format 1
    * @param time in standard format 2
    * @return boolean
    */
    func isOfTheSameDay(dateTimeInStandardFormat1: String, dateTimeInStandardFormat2: String) -> Bool {
        let date1Day = dateTimeInStandardFormat1.substringToIndex(10)
        let date2Day = dateTimeInStandardFormat2.substringToIndex(10)
        return date1Day == date2Day
    }

    /**
    * Check whether two DatesTimes written in the starndard format have the same year
    * @param time in standard format 1
    * @param time in standard format 2
    * @return boolean
    */
    func isOfTheSameYear(dateTimeInStandardFormat1: String, dateTimeInStandardFormat2: String) -> Bool {
        let date1Year = dateTimeInStandardFormat1.substringToIndex(4)
        let date2Year = dateTimeInStandardFormat2.substringToIndex(4)
        return date1Year == date2Year
    }

    /**
    * Get the display date from unix time, the display is typically be on the list view
    * @param unix time
    * @return time in display format
    */
    func getDisplayDateTime(dateTimeInUnix: Int) -> String {
        let dateTimeInStandardFormat = getDateTimeInStandardFormat(dateTimeInUnix)
        let todayInStandardFormat = getDateTimeOfTodayInStandardFormat()
        let tomorrowInStandardFormat = getDateTimeOfIthDateFromTodayInStandardFormat(1)
        
        let targetFormat = NSDateFormatter()
        if (isDateTimeSpecifiedTheHour(dateTimeInStandardFormat)) {
            if (isOfTheSameDay(dateTimeInStandardFormat, dateTimeInStandardFormat2: todayInStandardFormat)) {
                targetFormat.dateFormat = "'TODAY @' h:mm a"
            } else if (isOfTheSameDay(dateTimeInStandardFormat, dateTimeInStandardFormat2: tomorrowInStandardFormat)) {
                targetFormat.dateFormat = "'TOMORROW @' h:mm a"
            } else if (isOfTheSameYear(dateTimeInStandardFormat, dateTimeInStandardFormat2: todayInStandardFormat)) {
                targetFormat.dateFormat = "EEE, MMM d '@' h:mm a"
            } else {
                targetFormat.dateFormat = "EEE, MMM d, yyyy '@' h:mm a"
            }
        } else {   //the date did not specified the hours
            if (isOfTheSameDay(dateTimeInStandardFormat, dateTimeInStandardFormat2: todayInStandardFormat)) {
                return "TODAY"
            } else if (isOfTheSameDay(dateTimeInStandardFormat, dateTimeInStandardFormat2: tomorrowInStandardFormat)) {
                return "TOMORROW"
            } else if (isOfTheSameYear(dateTimeInStandardFormat, dateTimeInStandardFormat2: todayInStandardFormat)) {
                targetFormat.dateFormat = "EEE, MMM d"
            } else {
                targetFormat.dateFormat = "EEE, MMM d, yyyy"
            }
        }
        
        let standardFormat = NSDateFormatter()
        standardFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = standardFormat.dateFromString(dateTimeInStandardFormat)
        let formatedDisplayDate = targetFormat.stringFromDate(date)
        
        return formatedDisplayDate
    }

    /**
    * Get the display date from the unix time, the display time if typically tie to the detail view
    * @param unix time 1 (start time)
    * @param unix time 2 (end time)
    * @return time frame in display format
    */
    func getDisplayDateTime(startTimeInUnix: Int, endTimeInUnix: Int) -> String {
        if (endTimeInUnix == 0) {
            return getDisplayDateTime(startTimeInUnix)
        } else {
            var displayDateTime = getDisplayDateTime(startTimeInUnix)
            let dateTimeInStandardFormat1 = getDateTimeInStandardFormat(startTimeInUnix)
            let dateTimeInStandardFormat2 = getDateTimeInStandardFormat(endTimeInUnix)
            if (isOfTheSameDay(dateTimeInStandardFormat1, dateTimeInStandardFormat2: dateTimeInStandardFormat2)) {
                displayDateTime += " - " + getDisplayHour(endTimeInUnix)
            } else {
                displayDateTime += " - " + getDisplayDateTime(endTimeInUnix)
            }
            return displayDateTime
        }
    }






    //FROM HERE ON OUT, THESE FUNCTION WILL HELP CLASSIFY THE DATETIME INTO CATEGORY BY PROVIDE THE FRAME FOR EACH CATEGORY
    /**
    * Get the time frame of today
    * @return (start time in unix, end time in unix) tuple
    */
    func getTodayTimeFrame() -> (startTimeInUnix: Int, endTimeInUnix: Int) {
        let startTime = getUnixTime(getDateTimeOfTodayInStandardFormat())
        let endTime = getUnixTime(getDateTimeOfIthDateFromTodayInStandardFormat(1))
        return (startTime, endTime)
    }

    /**
    * Get today date name, this is to find the index of the date in week
    * @return today's date name
    */
    func getTodayDateName() -> String {
        let dateNameFormat = NSDateFormatter()
        dateNameFormat.dateFormat = "EEE"
        
        let date = NSDate()
        let dateNameFormatDate = dateNameFormat.stringFromDate(date)
        return dateNameFormatDate.uppercaseString
    }

    /**
    * Get index of today in the week starting with Monday
    * @return index of today in the week
    */
    func getTodayDateIndexInWeek() -> Int {
        let todayDateName = getTodayDateName()
        let dateNamesInWeek: String[] = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        for (index, value) in enumerate(dateNamesInWeek) {
            if (todayDateName == value) {
                return index;
            }
        }
        return -1
    }

    /**
    * Get the time frame for this week's weekend
    * @return (start time in unix, end time in unix)
    */
    func getThisWeekendTimeFrame() -> (startTimeInUnix: Int, endTimeInUnix: Int) {
        let todayDateIndexInWeek = getTodayDateIndexInWeek()
        var startingDateIndexFromToday = 5 - todayDateIndexInWeek
        if (startingDateIndexFromToday < 0) {
            startingDateIndexFromToday = 0
        }
        var endingDateIndexFromToday = 7 - todayDateIndexInWeek
        
        let startTime = getUnixTime(getDateTimeOfIthDateFromTodayInStandardFormat(startingDateIndexFromToday))
        let endTime = getUnixTime(getDateTimeOfIthDateFromTodayInStandardFormat(endingDateIndexFromToday))
        
        return (startTime, endTime)
    }

    /**
    * Get this week's timeframe
    * @return (start time in unix, end time in unix)
    */
    func getThisWeekTimeFrame() -> (startTimeInUnix: Int, endTimeInUnix: Int) {
        let todayTimeFrame = getTodayTimeFrame()
        let thisWeekendTimeFrame = getThisWeekendTimeFrame()
        return (todayTimeFrame.startTimeInUnix, thisWeekendTimeFrame.endTimeInUnix)
    }

    /**
    * Get next week's timeframe
    * @return (start time in unix, end time in unix)
    */
    func getNextWeekTimeFrame() -> (startTimeInUnix: Int, endTimeInUnix:Int) {
        let thisWeekTimeFrame =  getThisWeekTimeFrame()
        return (thisWeekTimeFrame.endTimeInUnix, thisWeekTimeFrame.endTimeInUnix + 60*60*24*7) //add 7 more days
    }

}
