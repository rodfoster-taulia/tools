// Script to get list of builds older than a specific date
import jenkins.model.*
import hudson.model.*
import java.util.Calendar

// Parameter: Specify how many years to look back
def yearsToLookBack = 1  // Number of years to look back

// Get the current date and time
def now = Calendar.getInstance()

// Calculate the date for X years ago (based on the parameter)
def targetDate = now.clone()
targetDate.add(Calendar.YEAR, -yearsToLookBack)

// List to store builds older than X years
def oldBuilds = []

// Iterate through all jobs in Jenkins
Jenkins.instance.getAllItems(Job.class).each { job ->
    // Iterate through all builds for each job
    job.getBuilds().each { build ->
        def buildTime = build.getTimeInMillis()
        
        // Check if the build is older than X years
        if (buildTime < targetDate.timeInMillis) {
            oldBuilds << [
                'jobName': job.getFullName(),
                'buildNumber': build.getNumber(),
                'buildDate': build.getTimestampString()
            ]
        }
    }
}

// Output the list of builds older than X years
if (oldBuilds.size() > 0) {
    println "Builds older than ${yearsToLookBack} year(s):"
    oldBuilds.each { entry ->
        println "Job: ${entry['jobName']} - Build: ${entry['buildNumber']} - Date: ${entry['buildDate']}"
    }
} else {
    println "No builds older than ${yearsToLookBack} year(s) found."
}
