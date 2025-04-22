import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.ame.Salary.dev"
            resValue(type = "string", name = "app_name", value = "シンプル給料記録アプリ Debug")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.ame.Salary.stg"
            resValue(type = "string", name = "app_name", value = "シンプル給料記録アプリ Staging")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.ame.Salary"
            resValue(type = "string", name = "app_name", value = "シンプル給料記録アプリ")
        }
    }
}