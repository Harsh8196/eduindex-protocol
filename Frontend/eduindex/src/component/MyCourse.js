import React, { useEffect, useState } from 'react'
import MetaMaskOnboarding from '@metamask/onboarding';
import '../css/MyCourse.css'
import { Link } from 'react-router-dom';
import EduxHub from '../script/EduxHub'
import web3 from '../script/web3_'
import { CourseDeployments, LoadingContainer } from "./Loading"
import { qGetProfile, qGetCourseByProfile, qGetCourseCollectData, qGetCourseCollectedByProfile, qGetCourseByPublication, qGetAllLessonForCourse, qGetCompletedLesson } from '../script/queries';
import { request } from 'graphql-request'

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;

function MyCourse() {
    const [accounts, setAccounts] = useState('');
    const [isLoading, setIsLoading] = useState(true)
    const [allMyCourses, setAllMyCourses] = useState([])
    const [allPurchaseCourses, setAllPurchaseCourses] = useState([])
    const [loading, setLoading] = useState(true)
    const [isMyCourseExists, setIsMyCourseExists] = useState(false)
    const [isPurchaseCourseExists, setIsPurchaseCourseExists] = useState(false)
    const [profileId, setProfileId] = useState(0)
    const [btnValue, setBtnValue] = useState('')

    useEffect(() => {
        function handleNewAccounts(newAccounts) {
            setAccounts(newAccounts);
        }
        async function onboarding() {
            if (MetaMaskOnboarding.isMetaMaskInstalled()) {
                await window.ethereum
                    .request({ method: 'eth_requestAccounts' })
                    .then(handleNewAccounts);
                await window.ethereum.on('accountsChanged', handleNewAccounts);
                return async () => {
                    await window.ethereum.off('accountsChanged', handleNewAccounts);
                };
            }
        }
        onboarding()
    }, []);

    useEffect(() => {
        if (accounts.length > 0) {
            getProfile()
        }

    }, [accounts])

    useEffect(() => {
        if (profileId > 0) {
            getAllMyCourses()
            getAllPurchaseCourses()
        }

    }, [profileId])

    const getProfile = async () => {
        const queryParameters = {
            "to": accounts[0].toString()
        }
        const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
        if (response.profileCreateds.length > 0) {
            setProfileId(response.profileCreateds[0].profileId)
            return response.profileCreateds[0].profileId
            // //console.log(result)
        } else {
            setProfileId(0)
            return 0
        }
    }

    const getAllMyCourses = async () => {
        setIsLoading(false);
        try {
            let courses = []
            let qResult = await request(process.env.REACT_APP_GRAPH_URL, qGetCourseByProfile, { "profileId": profileId })
            if (qResult.courseCreateds.length > 0) {
                let totalCourse = qResult.courseCreateds.length
                for (let i = 0; i < totalCourse; i++) {
                    let _course = qResult.courseCreateds[i]
                    let qResultCourseCollect = await request(process.env.REACT_APP_GRAPH_URL, qGetCourseCollectData, { "publicationId": _course["pubId"] })
                    let response = await fetch('https://ipfs.infura.io:5001/api/v0/get?arg=' + _course["courseParams_contentURI"], {
                        method: 'POST',
                        headers: {
                            "Authorization": "Basic " + btoa(projectId + ":" + projectSecret)
                        }
                    })
                    let IPFSData = await response.text()
                    const startIndex = IPFSData.indexOf("{")
                    const endIndex = IPFSData.indexOf("}")
                    const data = JSON.parse(IPFSData.substring(startIndex, endIndex + 1))
                    //console.log(data)
                    let publication = await EduxHub.methods.getPublication(_course["courseParams_profileId"], _course["pubId"]).call()
                    let courseObj = {
                        'coursename': data.courseName,
                        'coursedesc': data.courseDesc,
                        'authordesc': data.authorDesc,
                        'coursefee': web3.utils.fromWei(data.courseFee, 'ether'),
                        'courseUseCount': qResultCourseCollect.collecteds.length,
                        'pubId': _course["pubId"],
                        'totalLessons': publication.totalLesson.toString(),
                        'pubProfileId': _course["courseParams_profileId"]
                    }
                    courses.push(courseObj)
                }
                //console.log(courses)
                setAllMyCourses(courses)
                setIsMyCourseExists(true)
            } else {
                setIsMyCourseExists(false)
            }
            setIsLoading(true)
        } catch (error) {
            //console.log(error)
            setIsLoading(true)
        }
    }

    const getAllPurchaseCourses = async () => {
        setIsLoading(false);
        try {
            let courses = []
            let qResult = await request(process.env.REACT_APP_GRAPH_URL, qGetCourseCollectedByProfile, { "profileId": profileId })
            if (qResult.collecteds.length > 0) {
                let totalCourse = qResult.collecteds.length
                for (let i = 0; i < totalCourse; i++) {
                    let _course = qResult.collecteds[i]
                    let qResultCourseCollect = await request(process.env.REACT_APP_GRAPH_URL, qGetCourseByPublication, { "publicationId": _course["publicationCollectParams_publicationCollectedId"] })
                    //console.log(qResultCourseCollect)
                    _course = qResultCourseCollect.courseCreateds[0]
                    let response = await fetch('https://ipfs.infura.io:5001/api/v0/get?arg=' + _course["courseParams_contentURI"], {
                        method: 'POST',
                        headers: {
                            "Authorization": "Basic " + btoa(projectId + ":" + projectSecret)
                        }
                    })
                    let IPFSData = await response.text()
                    const startIndex = IPFSData.indexOf("{")
                    const endIndex = IPFSData.indexOf("}")
                    const data = JSON.parse(IPFSData.substring(startIndex, endIndex + 1))
                    // //console.log(data)
                    response = await request(process.env.REACT_APP_GRAPH_URL, qGetAllLessonForCourse, {
                        "pointedPubId": qResult.collecteds[i]["publicationCollectParams_publicationCollectedId"]
                    })
                    let allLessons = []
                    for (let i = 0; i < response.lessonCreateds.length; i++) {
                        allLessons.push(parseInt(response.lessonCreateds[i].pubId))
                    }
                    let publication = await EduxHub.methods.getPublication(_course["courseParams_profileId"], _course["pubId"]).call()
                    // //console.log( publication)
                    let completedLessons = await request(process.env.REACT_APP_GRAPH_URL, qGetCompletedLesson,
                        {
                            "pointedpublicationId": allLessons
                        })

                    let isCourseCompleted = await EduxHub.methods.isCourseCompleted(profileId, _course["courseParams_profileId"], _course["pubId"]).call()
                    console.log(isCourseCompleted)
                    let courseObj = {
                        'coursename': data.courseName,
                        'coursedesc': data.courseDesc,
                        'authordesc': data.authorDesc,
                        'coursefee': web3.utils.fromWei(data.courseFee, 'ether'),
                        'totalLessons': publication.totalLesson.toString(),
                        'completedLessons': completedLessons.progressCreateds.length,
                        'earnedRewards': web3.utils.fromWei(data.courseFee, 'ether'),
                        'pubId': _course["pubId"],
                        'pubProfileId': _course["courseParams_profileId"],
                        'isCourseCompleted': isCourseCompleted
                    }
                    courses.push(courseObj)
                }
                //console.log(courses)
                setAllPurchaseCourses(courses)
                setIsPurchaseCourseExists(true)
            } else {
                setIsPurchaseCourseExists(false)
            }
            setIsLoading(true)
        } catch (error) {
            //console.log(error)
            setIsLoading(true)
        }
    }

    const completeCourse = async (e) => {
        setLoading(false)
        e.preventDefault()
        //console.log(e.target.value)
        setBtnValue(e.target.value)
        try {
            let courseData = allPurchaseCourses.find(Course => Course.pubId === e.target.value)
            //console.log(courseData)
            let result = await EduxHub.methods.completeCourse(profileId, courseData["pubProfileId"], courseData["pubId"])
                .send({
                    from: accounts[0]
                })
            //console.log(result)
            setLoading(true)
            setBtnValue('')
            alert("Successfully completed the Course.")
            window.location.reload()
        } catch (error) {
            //console.log(error)
            setLoading(true)
            setBtnValue('')
            alert("Something went wrong. Please try again.")
        }
    }

    const MyCoursecard = () => {
        return (
            allMyCourses.map((course, index) =>
                <div className='col' key={index}>
                    <div className="card shadow rounded-4 card-CourseCatalog">
                        <div className="card-body">
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between align-items-center">
                                    <div className="text-clip">
                                        <h4 className="card-title"> {course["coursename"]} </h4>
                                    </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Fee {course["coursefee"]} WEDU </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Purchased By {course["courseUseCount"]} </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Total Lessons {course["totalLessons"]} </div>
                                </div>
                            </div>
                            <div className="row flex-grow-1">
                                <div className="col-12 d-flex flex-column justify-content-between">
                                    <p className="product-summary"> {course["coursedesc"]} </p>
                                </div>
                            </div>
                        </div>
                        <div className="card-footer d-flex justify-content-between rounded-bottom-4 align-items-center">
                            <Link className="btn btn-CourseCatalog" to={`/createlesson/` + course["pubId"] + `/` + course["pubProfileId"]}>
                                Create Lesson</Link>
                            <Link className="btn btn-CourseCatalog" to={`/coursedetails/` + course["pubId"] + `/` + course["pubProfileId"]}>
                                View Details</Link>
                        </div>
                    </div>
                </div>
            )
        )
    }
    const MyPurchasecard = () => {
        return (
            allPurchaseCourses.map((course, index) =>
                <div className='col' key={index}>
                    <div className="card shadow rounded-4 card-CourseCatalog">
                        <div className="card-body">
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between align-items-center">
                                    <div className="text-clip">
                                        <h4 className="card-title"> {course["coursename"]} </h4>
                                    </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Fee {course["coursefee"]} WEDU </div>
                                </div>
                            </div>
                            <div className="row" hidden={!course["isCourseCompleted"]}>
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Course Completed By Profile</div>
                                </div>
                            </div>
                            <div className="row flex-grow-1">
                                <div className="col-12 d-flex flex-column justify-content-between">
                                    <p className="product-summary"> {course["coursedesc"]} </p>
                                </div>
                            </div>
                        </div>
                        <div className="row d-flex justify-content-between">
                            <div className="col-8 ms-2">
                                <div className='fw-ligh'> Total Lessons </div>
                            </div>
                            <div className="col-3">
                                <div className="product-type"> {course["totalLessons"]} </div>
                            </div>
                        </div>
                        <div className="row d-flex justify-content-between">
                            <div className="col-8 ms-2">
                                <div className='fw-ligh'> Completed Lessons </div>
                            </div>
                            <div className="col-3">
                                <div className="product-type"> {course["completedLessons"]} </div>
                            </div>
                        </div>
                        {/* <div className="row d-flex justify-content-between">
                            <div className="col-8 ms-2">
                                <div className='fw-ligh'> Earned Rewards </div>
                            </div>
                            <div className="col-3">
                                <div className="product-type"> {course["earnedRewards"]} EDUXPT</div>
                            </div>
                        </div> */}

                        <div className="card-footer d-flex justify-content-between rounded-bottom-4 align-items-center">
                            <button className="btn btn-CourseCatalog" onClick={completeCourse} disabled={btnValue === course["pubId"] || (course["totalLessons"] != course["completedLessons"])} value={course["pubId"]}>
                                <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={btnValue !== course["pubId"]}></span>
                                Claim Certificate</button>
                            <Link className="btn btn-CourseCatalog" to={`/coursedetails/` + course["pubId"] + `/` + course["pubProfileId"]}>
                                View Details</Link>
                        </div>
                    </div>
                </div>
            )
        )
    }

    return (
        <div>
            <LoadingContainer isLoading={isLoading} />
            <div className="m-2" hidden={!isLoading}>
                <div className='MyCourseContainer'>
                    <div className='row mb-2'>
                        <div className="col-12">
                            <span className='fs-4 fw-light'>My Courses</span>
                        </div>
                    </div>
                    <CourseDeployments isLoading={!isLoading || isMyCourseExists} status={"You haven't deployed any course on Marketplace."} />
                    <div className='row row-cols-1 row-cols-md-2 g-2' hidden={!isMyCourseExists}>
                        <MyCoursecard />
                    </div>
                    <hr className="mt-2 mb-2" />
                    <div className='row mb-2'>
                        <div className="col-12">
                            <span className='fs-4 fw-light'>Purchased Course</span>
                        </div>
                    </div>
                    <CourseDeployments isLoading={!isLoading || isPurchaseCourseExists} status={"You haven't purchased any course from Marketplace."} />
                    <div className='row row-cols-1 row-cols-md-2 g-2' hidden={!isPurchaseCourseExists}>
                        <MyPurchasecard />
                    </div>
                </div>
            </div>
        </div>
    )
}

export default MyCourse