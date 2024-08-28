import React, { useState, useEffect } from 'react';
import '../css/CourseDetails.css'
import MetaMaskOnboarding from '@metamask/onboarding';
import EduxHub from '../script/EduxHub'
import { LoadingContainer } from "./Loading"
import { qGetProfile, qGetAllLessonForCourse, qGetCourseCollectedByProfile } from '../script/queries';
import { request } from 'graphql-request'
import { useParams } from 'react-router-dom';
import { create } from 'ipfs-http-client'
import web3 from '../script/web3_'
import { Buffer } from 'buffer';

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;
const auth = 'Basic ' + Buffer.from(projectId + ':' + projectSecret).toString('base64');
const ipfsClient = create({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
    headers: {
        authorization: auth,
    },
})

function CourseDetails() {
    let { pubid, pubprofileid } = useParams()
    const [accounts, setAccounts] = useState('')
    const [isLoading, setIsLoading] = useState(false)
    const [isCourseCollected, setIsCourseCollected] = useState(0)
    const [profileId, setProfileId] = useState(0)
    const [allLessons, setAllLessons] = useState([])
    const [btnValue, setBtnValue] = useState('')
    const [loading, setLoading] = useState(true)
    const [errorMessage, setErrorMessage] = useState('')

    useEffect(() => {
        handleaccounts()
    }, []);

    const handleaccounts = async () => {
        function handleNewAccounts(newAccounts) {
            setAccounts(newAccounts);
        }
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

    useEffect(() => {
        if (accounts.length > 0) {
            getProfile()
        }

    }, [accounts])

    useEffect(() => {
        if (profileId > 0) {
            getAllLesson()
        }

    }, [profileId, isCourseCollected])

    const getProfile = async () => {
        const queryParameters = {
            "to": accounts[0].toString()
        }
        const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
        if (response.profileCreateds.length > 0) {
            setProfileId(response.profileCreateds[0].profileId)
            const qCourseCollected = await request(process.env.REACT_APP_GRAPH_URL, qGetCourseCollectedByProfile, { "profileId": response.profileCreateds[0].profileId })
            setIsCourseCollected(qCourseCollected.collecteds.length)
            // //console.log(result)
        } else {
            setProfileId(0)
        }
        //console.log(response)
    }

    const getAllLesson = async () => {
        const queryParameters = {
            "pointedPubId": pubid
        }
        let lessons = []
        let response = await request(process.env.REACT_APP_GRAPH_URL, qGetAllLessonForCourse, queryParameters)
        if (response.lessonCreateds.length > 0) {
            let totalLesson = response.lessonCreateds.length
            let _lesson = response.lessonCreateds

            for (var i = 0; i < totalLesson; i++) {
                //console.log(_lesson[i])
                response = await fetch('https://ipfs.infura.io:5001/api/v0/get?arg=' + _lesson[i].lessonParams_contentURI, {
                    method: 'POST',
                    headers: {
                        "Authorization": "Basic " + btoa(projectId + ":" + projectSecret)
                    }
                })
                let IPFSData = await response.text()
                const startIndex = IPFSData.indexOf("{")
                const endIndex = IPFSData.indexOf("}")
                const data = JSON.parse(IPFSData.substring(startIndex, endIndex + 1))
                let isLessonCompleted = await EduxHub.methods.isLessonCompleted(profileId, _lesson[i].pubId).call()
                //console.log(isLessonCompleted)
                //console.log(isCourseCollected)
                let lessonObj = {
                    'lessonname': data.lessonName,
                    'lessondesc': data.lessonDesc,
                    'lessonreward': data.lessonReward + ' EDUXPT',
                    'pubId': _lesson[i].pubId,
                    'pubProfileId': _lesson[i].lessonParams_profileId,
                    'isLessonCompleted': isLessonCompleted,
                    'isCourseCollected': isCourseCollected,
                    'isButtonHidden': isCourseCollected === 0 || isLessonCompleted ? true : false,
                    'actionModuleAddress': _lesson[i].lessonParams_actionModules,
                    'earnedreward': isLessonCompleted ? data.lessonReward + ' EDUXPT' : 0 + ' EDUXPT'
                }
                lessons.push(lessonObj)
            }
            setAllLessons(lessons)
            // //console.log(result)
            setIsLoading(true)
        } else {
            setIsLoading(true)
        }

    }
    async function uploadData(lessonPubId, lessonReward) {

        try {
            const metaDataPath = await ipfsClient.add(JSON.stringify({
                coursePubId: pubid,
                lessonPubId: lessonPubId,
                lessonReward: lessonReward
            }))
            //console.log(metaDataPath)
            await ipfsClient.pin.add(metaDataPath.path.toString())
            return metaDataPath.path.toString()

        } catch (err) {
            //console.log(err)
            setErrorMessage("Opps! Somthing went wrong.")
            return 'error'
        }

    }

    const LessonCard = () => {
        return (
            allLessons.map((lesson, index) =>
                <div className="accordion-item" key={index}>
                    <h2 className="accordion-header" id="create-heading">
                        <button className='accordion-button fw-bold rounded-2 collapsed' type="button" data-bs-toggle="collapse" data-bs-target={`#create-collapse` + lesson["pubId"]} aria-expanded="true" aria-controls={`create-collapse` + lesson["pubId"]}>
                            {lesson["lessonname"]}
                        </button>
                    </h2>
                    <div id={`create-collapse` + lesson["pubId"]} className='accordion-collapse collapse' aria-labelledby="create-heading" data-bs-parent="#createFlush">
                        <div className="accordion-body">
                            <form>
                                <div className="mb-3 row">
                                    <label className="col-sm-2 col-form-label">Lesson Reward</label>
                                    <div className="col-sm-4">
                                        <input type="text" readOnly className="form-control-plaintext text-danger fw-bold" value={lesson["lessonreward"]} />
                                    </div>
                                    <label className="col-sm-2 col-form-label">Earned Reward</label>
                                    <div className="col-sm-4">
                                        <input type="text" readOnly className="form-control-plaintext text-danger fw-bold" value={lesson["earnedreward"]} />
                                    </div>
                                </div>
                                <hr />
                                <div className="mb-3 row">
                                    <div className="col-sm-12">
                                        <textarea type="text" readOnly className="form-control-plaintext" rows="20" value={lesson["lessondesc"]} />
                                    </div>
                                </div>
                                <div className="d-flex justify-content-between align-items-center">
                                    <button className="btn btn-CourseCatalog" onClick={completeLesson} disabled={btnValue === lesson["pubId"]} value={lesson["pubId"]} hidden={lesson["isButtonHidden"]}>
                                        <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={btnValue !== lesson["pubId"]}></span>
                                        Complete Lesson</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )
        )
    }

    const completeLesson = async (e) => {
        setLoading(false)
        e.preventDefault()
        //console.log(e.target.value)
        setBtnValue(e.target.value)
        try {
            let lessonData = allLessons.find(Lesson => Lesson.pubId === e.target.value)
            //console.log(lessonData)
            const CID = await uploadData(e.target.value, lessonData["lessonreward"])
            if (CID !== 'error') {
                let actionModuleInitData = web3.eth.abi.encodeParameters(["uint256"], [parseInt(lessonData["lessonreward"])]);
                let response = await EduxHub.methods.bulkprogress([[profileId, CID, lessonData["pubProfileId"], lessonData["pubId"]]]).send({
                    from: accounts[0]
                })
                //console.log(response)
                response = await EduxHub.methods.act([lessonData["pubProfileId"], lessonData["pubId"], profileId, lessonData["actionModuleAddress"], actionModuleInitData]).send({
                    from: accounts[0]
                })
                //console.log(response)
            }
            setLoading(true)
            setBtnValue('')
            alert("Lesson completed successfully.")
            window.location.reload()
        } catch (error) {
            //console.log(error)
            setLoading(true)
            setBtnValue('')
            alert("Something went wrong. Please try again.")
        }
    }

    return (
        <div className='container-fluid'>
            <LoadingContainer isLoading={isLoading} />
            <div className='row d-flex justify-content-center align-items-center'>
                <div className="mb-3 row" hidden={!isLoading}>
                    <label className="col-sm-2 col-form-label">Profile Address</label>
                    <div className="col-sm-10">
                        <span type='text'
                            className="form-control-plaintext"
                        >{accounts[0]} </span>
                    </div>
                </div>
                <div className="mb-3 row" hidden={!isLoading}>
                    <label className="col-sm-2 col-form-label">Profile Id</label>
                    <div className="col-sm-10">
                        <span type='text'
                            className="form-control-plaintext"
                        >{profileId} </span>
                    </div>
                </div>
                <div className='CourseDetailsContainer mb-2'>
                    <div className="card shadow rounded-2 p-2" hidden={!isLoading}>
                        <div className="accordion accordion-flush mt-2" id="createFlush">
                            <LessonCard />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}


export default CourseDetails