import React, { useEffect, useState } from 'react'
import MetaMaskOnboarding from '@metamask/onboarding';
import '../css/CourseCatalog.css'
import EduxHub from '../script/EduxHub'
import WEDU from '../script/WEDU'
import web3 from '../script/web3_'
import { NoDeployments, LoadingContainer } from "./Loading"
import { qGetAllCourse, qGetCourseCollectData, qGetProfile, qGetCourseCollectedByProfilePubId } from '../script/queries';
import { request } from 'graphql-request'
import { Link } from 'react-router-dom';

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;

function CourseCatalog() {
    const [accounts, setAccounts] = useState('');
    const [isLoading, setIsLoading] = useState(true)
    const [isCourseExists, setIsCourseExists] = useState(false)
    const [allCourses, setAllCourses] = useState([])
    const [loading, setLoading] = useState(true)
    const [btnValue, setBtnValue] = useState('')
    const [profileId, setProfileId] = useState(0)

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
            getAllCourses()
        }
    }, [accounts])


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

    const getAllCourses = async () => {
        setIsLoading(false);
        try {
            let courses = []
            let qResult = await request(process.env.REACT_APP_GRAPH_URL, qGetAllCourse)
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
                    ////console.log(data)
                    let publication = await EduxHub.methods.getPublication(_course["courseParams_profileId"], _course["pubId"]).call()
                    const qCourseCollected = await request(process.env.REACT_APP_GRAPH_URL, qGetCourseCollectedByProfilePubId,
                        {
                            "profileId": profileId,
                            "publicationId": _course["pubId"]
                        })
                    //publicationCollectParams_publicationCollectedId
                    let courseObj = {
                        'coursename': data.courseName,
                        'coursedesc': data.courseDesc,
                        'authordesc': data.authorDesc,
                        'coursefee': web3.utils.fromWei(data.courseFee, 'ether'),
                        'courseUseCount': qResultCourseCollect.collecteds.length,
                        'pubId': _course["pubId"],
                        "profileId": _course["courseParams_profileId"],
                        'collectModuleAddress': _course["courseParams_collectModule"],
                        'totalLessons': publication.totalLesson.toString(),
                        'isCollected': qCourseCollected.collecteds.length
                    }
                    courses.push(courseObj)
                }
                //console.log(courses)
                setAllCourses(courses)
                setIsCourseExists(true)
            } else {
                setIsCourseExists(false)
            }
            setIsLoading(true)
        } catch (error) {
            //console.log(error)
            setIsLoading(true)
        }

    }

    const Coursecard = () => {
        return (
            allCourses.map((Course, index) =>
                <div className='col' key={index}>
                    <div className="card shadow rounded-4 card-CourseCatalog">
                        <div className="card-body">
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between align-items-center">
                                    <div className="text-clip">
                                        <h4 className="card-title"> {Course["coursename"]} </h4>
                                    </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Fee {Course["coursefee"]} WEDU </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Purchased By {Course["courseUseCount"]} </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col-12 d-flex justify-content-between">
                                    <div className="product-type code"> Total Lessons {Course["totalLessons"]} </div>
                                </div>
                            </div>
                            <div className="row flex-grow-1">
                                <div className="col-12 d-flex flex-column justify-content-between">
                                    <p className="product-summary"> {Course["coursedesc"]} </p>
                                </div>
                            </div>
                        </div>
                        {/* <div className="row d-flex justify-content-between">
                            <div className="col-12 ms-2">
                                <div className='fw-ligh'> Verifier Address</div>
                            </div>
                        </div>
                        <div className="row d-flex justify-content-between">
                            <div className="col-12 ms-2">
                                <div className="product-type">{Course["verifier"]}</div>
                            </div>
                        </div> */}
                        {/* <div className="row d-flex justify-content-between">
                            <div className="col-12 ms-2">
                                <div className='fw-ligh'> Creator Address </div>
                            </div>
                        </div>
                        <div className="row d-flex justify-content-between">
                            <div className="col-12 ms-2">
                                <div className="product-type">{Course["creator"]}</div>
                            </div>
                        </div> */}
                        <div className="card-footer d-flex justify-content-between rounded-bottom-4 align-items-center">
                            <button className="btn btn-CourseCatalog" onClick={usecourse} disabled={btnValue === Course["pubId"] || Course["isCollected"] === 1} value={Course["pubId"]}>
                                <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={btnValue !== Course["pubId"]}></span>
                                Purchase Course</button>
                            <Link className="btn btn-CourseCatalog" to={`/coursedetails/` + Course["pubId"] + `/` + Course["profileId"]}>
                                View Details</Link>
                        </div>
                    </div>
                </div>
            )
        )
    }

    const usecourse = async (e) => {
        setLoading(false)
        e.preventDefault()
        //console.log(e.target.value)
        setBtnValue(e.target.value)
        try {
            let courseData = allCourses.find(Course => Course.pubId === e.target.value)
            //console.log(courseData)
            let feeWei = web3.utils.toWei(courseData.coursefee.toString(), 'ether')
            let collectModuleInitData = web3.eth.abi.encodeParameters(["address", "uint256"], [process.env.REACT_APP_WEDU_ADDRESS, feeWei]);
            let approve = await WEDU.methods.approve(courseData["collectModuleAddress"], feeWei).send({
                from: accounts[0]
            })
            //console.log(approve)
            let result = await EduxHub.methods.collect([courseData["profileId"], courseData["pubId"], profileId, process.env.REACT_APP_WEDU_ADDRESS, courseData["collectModuleAddress"], collectModuleInitData])
                .send({
                    from: accounts[0]
                })
            //console.log(result)
            setLoading(true)
            setBtnValue('')
            alert("Successfully purchased the Course.")
            window.location.reload()
        } catch (error) {
            //console.log(error)
            setLoading(true)
            setBtnValue('')
            alert("Something went wrong. Please try again.")
        }
    }

    return (
        <div>
            <LoadingContainer isLoading={isLoading} />
            <div className="m-2">
                <div className='CoursecatalogContainer' hidden={!isLoading}>
                    <div className='row'>
                        <div className="col-12">
                            <a className='btn btn-CourseCatalog float-end' href='\createcourse'>
                                Create Your Own Course
                            </a>
                        </div>
                    </div>
                    <NoDeployments isLoading={!isLoading || isCourseExists} status={`Course is not deployed yet.`} />
                    <div className='row mb-2' hidden={!isCourseExists}>
                        <div className="col-12">
                            <span className='fs-4 fw-light'>All Courses</span>
                        </div>
                    </div>
                    <div className='row row-cols-1 row-cols-md-2 g-2'>
                        <Coursecard />
                    </div>
                </div>
            </div>
        </div>
    )
}

export default CourseCatalog